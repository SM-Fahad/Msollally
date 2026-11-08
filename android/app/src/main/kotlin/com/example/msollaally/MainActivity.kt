package com.nodmac.abcd

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.net.URLConnection

class MainActivity : FlutterActivity() {
    companion object {
        private const val DOWNLOADS_CHANNEL = "msollaally/downloads"
        private const val STORAGE_PERMISSION_REQUEST_CODE = 1107
    }

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingPermissionCall: MethodCall? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DOWNLOADS_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> handleSaveToDownloads(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun handleSaveToDownloads(call: MethodCall, result: MethodChannel.Result) {
        val sourcePath = call.argument<String>("sourcePath")
        val fileName = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType")

        if (sourcePath.isNullOrBlank() || fileName.isNullOrBlank()) {
            result.error("invalid_args", "sourcePath and fileName are required.", null)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q &&
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            pendingPermissionResult = result
            pendingPermissionCall = call
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                STORAGE_PERMISSION_REQUEST_CODE
            )
            return
        }

        saveToDownloads(sourcePath, fileName, mimeType, result)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode != STORAGE_PERMISSION_REQUEST_CODE) {
            return
        }

        val result = pendingPermissionResult
        val call = pendingPermissionCall
        pendingPermissionResult = null
        pendingPermissionCall = null

        if (result == null || call == null) {
            return
        }

        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED

        if (!granted) {
            result.error(
                "permission_denied",
                "Storage permission is required to save files to Downloads.",
                null
            )
            return
        }

        val sourcePath = call.argument<String>("sourcePath")
        val fileName = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType")

        if (sourcePath.isNullOrBlank() || fileName.isNullOrBlank()) {
            result.error("invalid_args", "sourcePath and fileName are required.", null)
            return
        }

        saveToDownloads(sourcePath, fileName, mimeType, result)
    }

    private fun saveToDownloads(
        sourcePath: String,
        fileName: String,
        mimeType: String?,
        result: MethodChannel.Result
    ) {
        try {
            val sourceFile = File(sourcePath)
            if (!sourceFile.exists()) {
                result.error("missing_source", "Source file does not exist.", null)
                return
            }

            val normalizedMimeType = mimeType
                ?.substringBefore(";")
                ?.takeIf { it.isNotBlank() }
                ?: URLConnection.guessContentTypeFromName(fileName)
                ?: "application/octet-stream"

            val saved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                saveWithMediaStore(sourceFile, fileName, normalizedMimeType)
            } else {
                saveToLegacyDownloads(sourceFile, fileName, normalizedMimeType)
            }

            result.success(saved)
        } catch (e: Exception) {
            result.error("save_failed", e.message, null)
        }
    }

    private fun saveWithMediaStore(
        sourceFile: File,
        fileName: String,
        mimeType: String
    ): Map<String, String> {
        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }

        val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val uri = resolver.insert(collection, values)
            ?: throw IOException("Could not create a Downloads entry.")

        try {
            resolver.openOutputStream(uri)?.use { outputStream ->
                sourceFile.inputStream().use { inputStream ->
                    inputStream.copyTo(outputStream)
                }
            } ?: throw IOException("Could not open the Downloads output stream.")

            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }

        return mapOf(
            "uri" to uri.toString(),
            "location" to "Downloads/$fileName"
        )
    }

    @Suppress("DEPRECATION")
    private fun saveToLegacyDownloads(
        sourceFile: File,
        fileName: String,
        mimeType: String
    ): Map<String, String> {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS
        )
        if (!downloadsDir.exists() && !downloadsDir.mkdirs()) {
            throw IOException("Could not access the Downloads directory.")
        }

        val destination = createUniqueFile(downloadsDir, fileName)
        sourceFile.copyTo(destination, overwrite = false)

        MediaScannerConnection.scanFile(
            this,
            arrayOf(destination.absolutePath),
            arrayOf(mimeType),
            null
        )

        return mapOf(
            "uri" to destination.absolutePath,
            "location" to destination.absolutePath
        )
    }

    private fun createUniqueFile(directory: File, fileName: String): File {
        val dotIndex = fileName.lastIndexOf('.')
        val baseName = if (dotIndex > 0) fileName.substring(0, dotIndex) else fileName
        val extension = if (dotIndex > 0) fileName.substring(dotIndex) else ""

        var candidate = File(directory, fileName)
        var counter = 1
        while (candidate.exists()) {
            candidate = File(directory, "$baseName ($counter)$extension")
            counter += 1
        }
        return candidate
    }
}
