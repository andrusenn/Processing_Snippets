import gab.opencv.*;
import hidensource.ablobsystem.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;

// Depth image
PImage depthImg;

// Which pixels do we care about?
float minDepth =  50;
float maxDepth = 80;

// What is the kinect's angle
float angle;
ABlobSystem bs;
ArrayList<ABlob> blobs;
PImage low_res;
void setup() {
  size(640, 480);
  low_res = createImage(320, 240, RGB);
  kinect = new Kinect(this);
  kinect.initDepth();
  angle = kinect.getTilt();
  bs = new ABlobSystem(this, 320, 240);
  // Blank image
  depthImg = new PImage(kinect.width, kinect.height);
}

void draw() {
  // Threshold the depth image
  int[] rawDepth = kinect.getRawDepth();
  for (int i = 0; i < rawDepth.length; i++) {
    float m = rawDepthToCM(rawDepth[i]);
    if (m >= minDepth && m <= maxDepth) {
      depthImg.pixels[i] = color(255);
    } else {
      depthImg.pixels[i] = color(0);
    }
  }
  // Draw the thresholded image
  depthImg.updatePixels();
  low_res.copy(depthImg, 0, 0, depthImg.width, depthImg.height, 0, 0, 320, 240);
  blobs = bs.getBlobs(low_res);

  for (ABlob b : blobs) {
  }
  image(low_res, 0, 0);
  bs.drawBox(true, true);
}

// Adjust the angle and the depth threshold min and max
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angle++;
    } else if (keyCode == DOWN) {
      angle--;
    }
    angle = constrain(angle, 0, 30);
    kinect.setTilt(angle);
  } else if (key == 'a') {
    minDepth = constrain(minDepth+10, 0, maxDepth);
  } else if (key == 's') {
    minDepth = constrain(minDepth-10, 0, maxDepth);
  } else if (key == 'z') {
    maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } else if (key =='x') {
    maxDepth = constrain(maxDepth-10, minDepth, 2047);
  }
}
// Convierte los datos devueltos en metros
//
float rawDepthToMeters(int depthValue) {
  // 2047 es los máximo para kinect 1
  // Kinect 2 4094?
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}
float rawDepthToCM(int depthValue) {
  // 2047 es los máximo para kinect 1
  // Kinect 2 4094?
  if (depthValue < 2047) {
    return (float)(100.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}