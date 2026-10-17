package com.kaitechcorp.travelcrew

import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "travelcrew/calendar")
            .setMethodCallHandler { call, result ->
                if (call.method != "addTrip" && call.method != "addActivity") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    // CalendarContract uses UTC midnight for all-day dates.
                    val format = SimpleDateFormat("yyyy-MM-dd", Locale.US).apply {
                        timeZone = TimeZone.getTimeZone("UTC")
                        isLenient = false
                    }
                    val timed = call.method == "addActivity"
                    val start = if (timed) requireNotNull(call.argument<Number>("startMilliseconds")).toLong()
                        else format.parse(requireNotNull(call.argument<String>("startDate")))!!.time
                    val end = if (timed) requireNotNull(call.argument<Number>("endMilliseconds")).toLong()
                        else format.parse(requireNotNull(call.argument<String>("endDate")))!!.time
                    require(end > start)
                    val intent = Intent(Intent.ACTION_INSERT).apply {
                        data = CalendarContract.Events.CONTENT_URI
                        putExtra(CalendarContract.Events.TITLE, call.argument<String>("title"))
                        putExtra(CalendarContract.Events.EVENT_LOCATION, call.argument<String>("location"))
                        putExtra(CalendarContract.Events.DESCRIPTION, call.argument<String>("notes"))
                        putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, !timed)
                        putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, start)
                        putExtra(CalendarContract.EXTRA_EVENT_END_TIME, end)
                    }
                    startActivity(intent)
                    result.success(null)
                } catch (_: ActivityNotFoundException) {
                    result.error("unavailable", "No calendar app is installed", null)
                } catch (_: Exception) {
                    result.error("calendar_error", "Unable to open the calendar event", null)
                }
            }
    }
}
