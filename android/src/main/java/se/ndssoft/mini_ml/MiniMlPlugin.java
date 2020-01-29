package se.ndssoft.mini_ml;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabel;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabeler;
import com.google.firebase.ml.vision.objects.FirebaseVisionObject;
import com.google.firebase.ml.vision.objects.FirebaseVisionObjectDetector;
import com.google.firebase.ml.vision.objects.FirebaseVisionObjectDetectorOptions;

import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * MiniMlPlugin
 */
public class MiniMlPlugin implements FlutterPlugin, MethodCallHandler {

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/mini_ml");
        channel.setMethodCallHandler(new MiniMlPlugin());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {


        FirebaseVisionImage image = null;

        byte[] bytes = call.argument("binary");
        BitmapFactory.Options bounds = new BitmapFactory.Options();
        bounds.inJustDecodeBounds = true;
        BitmapFactory.decodeByteArray(bytes, 0, bytes.length, bounds);
        BitmapFactory.Options opts = new BitmapFactory.Options();
        Bitmap bm = BitmapFactory.decodeByteArray(bytes, 0, bytes.length, opts);
        Matrix matrix = new Matrix();
        matrix.setRotate(90, (float) bm.getWidth() / 2, (float) bm.getHeight() / 2);
        Bitmap rotatedBitmap = Bitmap.createBitmap(bm, 0, 0, bounds.outWidth, bounds.outHeight, matrix, true);
        image = FirebaseVisionImage.fromBitmap(rotatedBitmap);

        if (call.method.startsWith("FirebaseVisionObjectDetector#detectFrom")) {
            FirebaseVisionObjectDetectorOptions options =
                    new FirebaseVisionObjectDetectorOptions.Builder()
                            .setDetectorMode(FirebaseVisionObjectDetectorOptions.SINGLE_IMAGE_MODE)
                            //  .setDetectorMode(FirebaseVisionObjectDetectorOptions.STREAM_MODE)
                            // .enableMultipleObjects()
                            // .enableClassification()  // Optional
                            .build();

            FirebaseVisionObjectDetector detector = FirebaseVision.getInstance()
                    .getOnDeviceObjectDetector(options);
            //  .getOnDeviceObjectDetector();
            detector.processImage(image)
                    .addOnSuccessListener(
                            new OnSuccessListener<List<FirebaseVisionObject>>() {
                                @Override
                                public void onSuccess(List<FirebaseVisionObject> detectedObjects) {
                                    result.success(processObjectDetectionResult(detectedObjects));
                                }
                            })
                    .addOnFailureListener(
                            new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                    // Task failed with an exception
                                    e.printStackTrace();
                                }
                            });

        } else if (call.method.startsWith("FirebaseVisionLabelDetector#detectFrom")) {
            boolean cloud = call.argument("cloud");
            FirebaseVisionImageLabeler detector;
            if (cloud)
                detector = FirebaseVision.getInstance()
                        .getCloudImageLabeler();
            else detector = FirebaseVision.getInstance()
                    .getOnDeviceImageLabeler();
            detector.processImage(image)
                    .addOnSuccessListener(
                            new OnSuccessListener<List<FirebaseVisionImageLabel>>() {
                                @Override
                                public void onSuccess(List<FirebaseVisionImageLabel> labels) {
                                    result.success(processImageLabelingResult(labels));
                                }
                            })
                    .addOnFailureListener(
                            new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                    // Task failed with an exception
                                    e.printStackTrace();
                                }
                            });

        } else {
            result.notImplemented();
        }

    }

    private ImmutableList<ImmutableMap<String, Object>> processObjectDetectionResult(List<FirebaseVisionObject> detectedObjects) {
        ImmutableList.Builder<ImmutableMap<String, Object>> dataBuilder =
                ImmutableList.<ImmutableMap<String, Object>>builder();

        for (FirebaseVisionObject obj : detectedObjects) {
            ImmutableMap.Builder<String, Object> objectBuilder = ImmutableMap.<String, Object>builder();
            // Integer id = obj.getTrackingId();
            objectBuilder.put("rect_bottom", (double) obj.getBoundingBox().bottom);
            objectBuilder.put("rect_top", (double) obj.getBoundingBox().top);
            objectBuilder.put("rect_right", (double) obj.getBoundingBox().right);
            objectBuilder.put("rect_left", (double) obj.getBoundingBox().left);

            dataBuilder.add(objectBuilder.build());
        }
        return dataBuilder.build();
    }

    private ImmutableList<ImmutableMap<String, Object>> processImageLabelingResult(List<FirebaseVisionImageLabel> labels) {
        ImmutableList.Builder<ImmutableMap<String, Object>> dataBuilder =
                ImmutableList.<ImmutableMap<String, Object>>builder();

        for (FirebaseVisionImageLabel label : labels) {
            ImmutableMap.Builder<String, Object> labelBuilder = ImmutableMap.<String, Object>builder();

            labelBuilder.put("label", label.getText());
            labelBuilder.put("entityID", label.getEntityId());
            labelBuilder.put("confidence", label.getConfidence());

            dataBuilder.add(labelBuilder.build());
        }

        return dataBuilder.build();
    }

}





