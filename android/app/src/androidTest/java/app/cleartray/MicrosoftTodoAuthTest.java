package app.cleartray;

import static org.junit.Assert.*;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnit4;
import java.util.List;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class MicrosoftTodoAuthTest {
    @Test public void browserCallbackSharesTheFlutterHostsTaskAffinity() throws Exception {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        PackageManager pm = context.getPackageManager();
        String appId = context.getPackageName();
        ActivityInfo host = pm.getActivityInfo(new ComponentName(appId, "app.cleartray.MainActivity"), 0);
        ActivityInfo manager = pm.getActivityInfo(new ComponentName(appId,
            "net.openid.appauth.AuthorizationManagementActivity"), 0);
        ActivityInfo receiver = pm.getActivityInfo(new ComponentName(appId,
            "net.openid.appauth.RedirectUriReceiverActivity"), 0);

        // A callback must find the pending authorization activity in the host's
        // task. A new activity has no request/PKCE state and cannot finish login.
        assertEquals(appId, host.taskAffinity);
        assertEquals(host.taskAffinity, manager.taskAffinity);
        assertEquals(host.taskAffinity, receiver.taskAffinity);
        assertEquals(ActivityInfo.LAUNCH_SINGLE_TASK, manager.launchMode);
        // Icon entrypoints create the initial task before handing it to Flutter.
        for (String icon : new String[]{"Amber", "Blue", "Cyan", "Teal", "Green", "Violet", "Rose"}) {
            ActivityInfo launcher = pm.getActivityInfo(new ComponentName(appId,
                "app.cleartray.Launcher" + icon), PackageManager.MATCH_DISABLED_COMPONENTS);
            assertEquals("Launcher" + icon, host.taskAffinity, launcher.taskAffinity);
        }
    }

    @Test public void callbackResolvesOnlyToThisBuildsAppAuthReceiver() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        String appId = context.getPackageName();
        boolean debug = appId.endsWith(".debug");
        String own = debug ? "app.cleartray.microsoft.debug" : "app.cleartray.microsoft";
        String other = debug ? "app.cleartray.microsoft" : "app.cleartray.microsoft.debug";
        List<ResolveInfo> receivers = callbacks(context, own);
        assertEquals(1, receivers.size());
        assertEquals("net.openid.appauth.RedirectUriReceiverActivity", receivers.get(0).activityInfo.name);
        assertTrue(receivers.get(0).activityInfo.exported);
        assertTrue(callbacks(context, other).isEmpty());
    }

    private List<ResolveInfo> callbacks(Context context, String scheme) {
        Intent callback = new Intent(Intent.ACTION_VIEW, Uri.parse(scheme + "://oauth/callback"))
            .addCategory(Intent.CATEGORY_BROWSABLE).setPackage(context.getPackageName());
        return context.getPackageManager().queryIntentActivities(callback, PackageManager.MATCH_DEFAULT_ONLY);
    }
}
