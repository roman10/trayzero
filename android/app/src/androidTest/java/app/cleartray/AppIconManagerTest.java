package app.cleartray;

import static org.junit.Assert.*;
import android.content.ComponentName;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.content.Context;
import android.content.res.Configuration;
import android.util.TypedValue;
import android.view.ContextThemeWrapper;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnit4;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import androidx.test.runner.lifecycle.ActivityLifecycleCallback;
import androidx.test.runner.lifecycle.ActivityLifecycleMonitorRegistry;
import androidx.test.runner.lifecycle.Stage;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class AppIconManagerTest {
    @Test public void notificationResourceSurvivesPackagingAndHasTransparentBackground() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        int resource = context.getResources().getIdentifier("ic_stat_trayzero", "drawable", context.getPackageName());
        assertNotEquals(0, resource);
        Drawable glyph = context.getDrawable(resource);
        Bitmap bitmap = Bitmap.createBitmap(24, 24, Bitmap.Config.ARGB_8888);
        glyph.setBounds(0, 0, 24, 24);
        glyph.draw(new Canvas(bitmap));
        assertEquals(0, Color.alpha(bitmap.getPixel(0, 0)));
        assertEquals(255, Color.alpha(bitmap.getPixel(12, 10)));
        assertEquals(0, Color.alpha(bitmap.getPixel(12, 16)));
    }

    @Test public void launchThemesUseNeutralDayNightBackgroundsAndSelectedArtwork() throws Exception {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        PackageManager pm = context.getPackageManager();
        for (int night : new int[]{Configuration.UI_MODE_NIGHT_NO, Configuration.UI_MODE_NIGHT_YES}) {
            Configuration configuration = new Configuration(context.getResources().getConfiguration());
            configuration.uiMode = (configuration.uiMode & ~Configuration.UI_MODE_NIGHT_MASK) | night;
            Context configured = context.createConfigurationContext(configuration);
            for (String icon : new String[]{"amber", "blue", "cyan", "teal", "green", "violet", "rose"}) {
                ComponentName launcher = new ComponentName(context.getPackageName(),
                    "app.cleartray.Launcher" + Character.toUpperCase(icon.charAt(0)) + icon.substring(1));
                int theme = pm.getActivityInfo(launcher, PackageManager.MATCH_DISABLED_COMPONENTS).getThemeResource();
                Context themed = new ContextThemeWrapper(configured, theme);
                TypedValue background = new TypedValue();
                assertTrue(themed.getTheme().resolveAttribute(androidx.core.splashscreen.R.attr.windowSplashScreenBackground, background, true));
                assertEquals(night == Configuration.UI_MODE_NIGHT_YES ? 0xff121212 : 0xfffafafa, background.data);
                TypedValue artwork = new TypedValue();
                assertTrue(themed.getTheme().resolveAttribute(androidx.core.splashscreen.R.attr.windowSplashScreenAnimatedIcon, artwork, true));
                assertEquals(context.getResources().getIdentifier("splash_icon_" + icon, "drawable", context.getPackageName()), artwork.resourceId);
            }
        }
    }

    private MainActivity launchAndAwaitFlutter(Context context, String icon) throws Exception {
        return launchAndAwaitFlutter(context, new Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_LAUNCHER)
            .setClassName(context.getPackageName(), "app.cleartray.Launcher" + icon)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
    }

    private MainActivity launchAndAwaitFlutter(Context context, Intent intent) throws Exception {
        CountDownLatch resumed = new CountDownLatch(1);
        AtomicReference<MainActivity> host = new AtomicReference<>();
        ActivityLifecycleCallback callback = (activity, stage) -> {
            if (activity instanceof MainActivity && stage == Stage.RESUMED) {
                host.set((MainActivity) activity);
                resumed.countDown();
            }
        };
        ActivityLifecycleMonitorRegistry.getInstance().addLifecycleCallback(callback);
        try {
            context.startActivity(intent);
            assertTrue("Flutter host resumes", resumed.await(10, TimeUnit.SECONDS));
            return host.get();
        } finally {
            ActivityLifecycleMonitorRegistry.getInstance().removeLifecycleCallback(callback);
        }
    }

    @Test public void switchingIconAndRelaunchingReusesTheFlutterHost() throws Exception {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppIconManager icons = new AppIconManager(context);
        try {
            icons.setIcon("amber");
            MainActivity first = launchAndAwaitFlutter(context, "Amber");
            icons.setIcon("blue");
            assertSame("Icon changes must not create another Flutter engine", first,
                launchAndAwaitFlutter(context, "Blue"));
        } finally {
            icons.setIcon("amber");
        }
    }

    @Test public void directEntrypointsReuseTheLaunchedFlutterHostAndDeliverIntents() throws Exception {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppIconManager icons = new AppIconManager(context);
        icons.setIcon("amber");
        MainActivity first = launchAndAwaitFlutter(context, "Amber");
        InstrumentationRegistry.getInstrumentation().waitForIdleSync();
        InstrumentationRegistry.getInstrumentation().runOnMainSync(() -> first.moveTaskToBack(true));
        Intent notification = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
        notification.setAction("SELECT_NOTIFICATION").putExtra("payload", "splash-review-probe");
        assertSame("Notification entry must reuse the Flutter host", first,
            launchAndAwaitFlutter(context, notification));
        InstrumentationRegistry.getInstrumentation().waitForIdleSync();
        assertEquals("splash-review-probe", first.getIntent().getStringExtra("payload"));
        InstrumentationRegistry.getInstrumentation().runOnMainSync(() -> first.moveTaskToBack(true));
        Intent link = new Intent(Intent.ACTION_VIEW, Uri.parse("cleartray://capture"))
            .setClass(context, MainActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        assertSame("Deep links must reuse the Flutter host", first,
            launchAndAwaitFlutter(context, link));
    }

    @Test public void switchingKeepsOneLauncherAndStableNotificationTarget() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppIconManager icons = new AppIconManager(context);
        PackageManager pm = context.getPackageManager();
        try {
            for (String icon : new String[]{"blue", "cyan", "teal", "green", "violet", "rose", "amber"}) {
                assertEquals(icon, icons.setIcon(icon).get("icon"));
                // A new manager reads OS-persisted selection, not an in-memory setting.
                assertEquals(icon, new AppIconManager(context).state().get("icon"));
                int expectedTheme = context.getResources().getIdentifier("LaunchTheme." + Character.toUpperCase(icon.charAt(0)) + icon.substring(1), "style", context.getPackageName());
                assertEquals(expectedTheme, icons.splashTheme());
                Intent launcher = new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER).setPackage(context.getPackageName());
                List<ResolveInfo> entries = pm.queryIntentActivities(launcher, 0);
                assertEquals("Exactly one launcher entry", 1, entries.size());
                assertTrue(entries.get(0).activityInfo.name.endsWith("Launcher" + Character.toUpperCase(icon.charAt(0)) + icon.substring(1)));
                assertEquals(new ComponentName(context, MainActivity.class), pm.getLaunchIntentForPackage(context.getPackageName()).getComponent());
                assertNotEquals(PackageManager.COMPONENT_ENABLED_STATE_DISABLED, pm.getComponentEnabledSetting(new ComponentName(context, MainActivity.class)));
                Intent capture = new Intent(Intent.ACTION_VIEW, Uri.parse("cleartray://capture")).setPackage(context.getPackageName());
                assertEquals(MainActivity.class.getName(), pm.resolveActivity(capture, PackageManager.MATCH_DEFAULT_ONLY).activityInfo.name);
            }
            try {
                icons.setIcon("unknown");
                fail("Unknown icon must be rejected");
            } catch (IllegalArgumentException expected) { }
            assertEquals("amber", icons.state().get("icon"));
        } finally {
            icons.setIcon("amber");
        }
    }
}
