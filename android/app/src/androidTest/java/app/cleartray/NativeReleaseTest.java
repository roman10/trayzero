package app.cleartray;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

// Native instrumentation can read integration_test results in release mode;
// flutter test's VM-service runner cannot attach to a release build.
@RunWith(FlutterTestRunner.class)
public class NativeReleaseTest {
    @Rule
    public ActivityTestRule<MainActivity> activity =
        new ActivityTestRule<>(MainActivity.class, true, false);
}
