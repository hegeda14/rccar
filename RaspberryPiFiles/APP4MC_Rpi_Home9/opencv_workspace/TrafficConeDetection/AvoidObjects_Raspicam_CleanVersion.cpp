//Able to detect an orange object on a table with enough heightxwidth
//Very basic - not tested in many environments
//Compiled by: M.Ozcelikors <mozcelikors@gmail.com>

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>

#include <unistd.h>
#include <string.h>

#include <raspicam/raspicam.h>
#include <raspicam/raspicam_cv.h>
#include <ctime>

#include <fstream>

using namespace std;
using namespace cv;

char key;
char* output_window_name = "Camera Output";
char* grayscale_window_name = "Grayscale Image";
char* thresholded_window_name = "Thresholded Image";
char* contours_window_name = "Contours Image";


int canny_lowthreshold = 20;
int canny_highthreshold = 50;
int width_bound = 16;//5
int height_bound = 16;//5
int solidity_bound = 9;
int max_val = 200;
int float_max_val = 30;
int color_max_val = 256;

//Orange
int u_h=0;//0;//0;//0;  //0
int u_s=177;//148;//102;//134;//120; //197
int u_v=178;//149;//220;//212;//120; //189
int d_h=203;//5;//256;//256; //9
int d_s=256;//256; //256
int d_v=256;//256; //256

//White
int w_u_h = 0;
int w_u_s = 0;
int w_u_v = 177;
int w_d_h = 256;
int w_d_s = 49;
int w_d_v = 256;

int up_aspectRatio = 26;
int down_aspectRatio = 15;
int aspect_max_val = 50;
RNG rng(12345);

int detections_w[10];
int detections_h[10];
int detections_x[10];
int detections_y[10];
double  detections_wh[10];
int detection_count = 0;

int openings_w[10];
int openings_h[10];
int openings_x[10];
int openings_y[10];
int opening_count = 0;

int counter = 0;

void canny(int, void*){}

void error(const char *msg)
{
    perror(msg);
    exit(0);
}

//returns 1-openings are same    -1-openings are different
int compareOpenings(int opening_count, int opening_count_prev, int first_time_cmp_)
{
	if(first_time_cmp_ != 1)
	{
		if(abs(openings_y[opening_count]-openings_y[opening_count_prev])<20)
			return 1;
		else
			return -1;
	}
	else
	{
		return 1;
	}
}

int main(int argc, char *argv[])
{
    //Image processing
    //namedWindow(output_window_name, CV_WINDOW_AUTOSIZE);
    //namedWindow(grayscale_window_name, 100);
    //namedWindow(thresholded_window_name, 100);
    //namedWindow(contours_window_name, 100);

    //moveWindow(grayscale_window_name, 20,20);
    //moveWindow(thresholded_window_name, 20, 250);
    //moveWindow(contours_window_name, 20, 600);

    vector<int> compression_params;
    compression_params.push_back(CV_IMWRITE_JPEG_QUALITY);
    compression_params.push_back(100);

    //Raspberry Pi camera object
    raspicam::RaspiCam_Cv Camera;
    //Camera.set (CV_CAP_PROP_FORMAT, CV_8UC3);//CV_BGR2HSV); // Original format in Raspicam -> CV_8UC1);
    if (!Camera.open()){
      printf("Camera failed to open!\n");
      return -1;
    }
    
    Mat frame;
    Mat frameRGB;
    Mat imgGrayScale;
    Mat imgHsv;
    Mat imgRedThresh;
    Mat imgWhiteThresh;
    Mat imgResultingThresh;
    Mat edges;
    vector< vector<Point> > contours;
    vector< Vec4i > hierarchy;
    vector<Point> approx;
    vector<Point> tempCont;
    vector<vector<Point> > tempVecCont;
    double contPeri;
    Rect bBox;
    double aspectRatio;

    double area;
    double hullArea;
    double solidity;

    int opening_length;
    int opening_midpoint;

    int found_flag = 0;

    double maximum ;
    double second_maximum ;
    double third_maximum;
    int maximum_idx ;
    int second_maximum_idx ;
    int third_maximum_idx;
    double second_last_maximum;
    double last_maximum;

    // The below is for adjusting color h-s-v thresholds
    //createTrackbar("canny low Threshold: ", output_window_name, &canny_lowthreshold, max_val, canny);
    //createTrackbar("canny high Threshold: ", output_window_name, &canny_highthreshold, max_val, canny);
    //createTrackbar("height: ", output_window_name, &height_bound, float_max_val, canny);
    //createTrackbar("width: ", output_window_name, &width_bound, float_max_val, canny);
    //createTrackbar("solidity: ", output_window_name, &solidity_bound, float_max_val, canny);
    //createTrackbar("Up AspectRatio: ", output_window_name, &up_aspectRatio, aspect_max_val, canny);
    //createTrackbar("Down AspectRatio: ", output_window_name, &down_aspectRatio, aspect_max_val, canny);
    //createTrackbar("Up H: ", output_window_name, &u_h, color_max_val, canny);
    //createTrackbar("Up S: ", output_window_name, &u_s, color_max_val, canny);
    //createTrackbar("Up v: ", output_window_name, &u_v, color_max_val, canny);
    //createTrackbar("Down H: ", output_window_name, &d_h, color_max_val, canny);
    //createTrackbar("Down S: ", output_window_name, &d_s, color_max_val, canny);
    //createTrackbar("Down v: ", output_window_name, &d_v, color_max_val, canny);


    while(1){
        //Capture image with Raspicam_CV
        Camera.grab();
        Camera.retrieve(frame);  //cap >> frame

	//If you want to take a picture and save it as jpg:
	//cv::imwrite("raspicam_img.jpg", frame);
	
	printf("Starting...\n");
	frameRGB.create(frame.size(), frame.type());
	cvtColor(frame, frameRGB, CV_BGR2RGB);
	
        imgHsv.create(frameRGB.size(), frameRGB.type());
        cvtColor(frameRGB, imgHsv, CV_RGB2HSV);//HSV

        inRange(imgHsv, Scalar(u_h, u_s, u_v), Scalar(d_h, d_s, d_v), imgRedThresh);
          
        //converting the original image into grayscale
        imgGrayScale.create(frame.size(), frame.type());
        cvtColor(frame, imgGrayScale, CV_BGR2GRAY);
        bitwise_and(imgRedThresh, imgGrayScale, imgGrayScale);
	
        // Floodfill from point (0, 0)
        Mat im_floodfill = imgGrayScale.clone();
        floodFill(im_floodfill, cv::Point(0,0), Scalar(255));

        // Invert floodfilled image
        Mat im_floodfill_inv;
        bitwise_not(im_floodfill, im_floodfill_inv);

        // Combine the two images to get the foreground.
        imgGrayScale = (imgGrayScale | im_floodfill_inv);

        GaussianBlur(imgGrayScale, imgGrayScale, Size(7,7), 1.5, 1.5);

        //imshow(grayscale_window_name, imgGrayScale);

        edges.create(imgGrayScale.size(), imgGrayScale.type());
        Canny(imgGrayScale, edges, canny_lowthreshold, canny_highthreshold, 3);

        findContours(edges, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0,0));
        Mat drawing = Mat::zeros(edges.size(), CV_8UC3);

	//For all contours
        for(int i=0 ; i<contours.size() ; i++){
              contPeri = arcLength(contours.at(i), true);
              approxPolyDP(contours.at(i), approx,  0.01 * contPeri, true);

              bBox = boundingRect(approx);
              aspectRatio = bBox.width/bBox.height;

              area = contourArea(contours.at(i));
              convexHull(contours.at(i), tempCont);
              hullArea = contourArea(tempCont);
              solidity = area / hullArea;

              // cout << "contour : " << approx.size() << endl;
              // cout << bBox.width << "::" << bBox.height << "::" << solidity  << "::" << aspectRatio <<endl;

              tempVecCont.clear();
              tempVecCont.push_back(approx);

              if(bBox.width > width_bound && bBox.height > height_bound && solidity > solidity_bound/10/*&& aspectRatio >= down_aspectRatio/10 && aspectRatio <= up_aspectRatio/10*/ )
		{
		     //Find detections
		     //printf("%d\t%d\n",bBox.width, bBox.height);
		     detections_x[detection_count] = bBox.x;
		     detections_y[detection_count] = bBox.y;
		     detections_w[detection_count] = bBox.width;
		     detections_h[detection_count] = bBox.height;
		     detections_wh[detection_count] = bBox.width*bBox.height;
		     detection_count = detection_count + 1;
                }

          }
	  //First we shall select the biggest two boxes, having biggest w x h.
	  maximum = detections_wh[0];
          second_maximum = detections_wh[0];
	  third_maximum = detections_wh[0];
          maximum_idx = 0;
          second_maximum_idx = 0;
          third_maximum_idx = 0;
	  int c;
	  for (c = 0; c < detection_count; c++)
	  {
		    if (detections_wh[c] > maximum)
		    {
                       third_maximum = second_maximum;
		       third_maximum_idx = second_maximum_idx;
		       second_maximum = maximum;
                       second_maximum_idx = maximum_idx;
		       maximum  = detections_wh[c];
                       maximum_idx = c;
		    }
	  }

	  
	  //printf("1. x = %d\n",detections_x[maximum_idx]);
	  //printf("2. x = %d\n",detections_x[second_maximum_idx]);
	  //printf("1. y = %d\n",detections_y[maximum_idx]);
	  //printf("2. y = %d\n",detections_y[second_maximum_idx]);

          printf("maximum=%f\n",maximum);
	  if(maximum > 10000 || second_maximum > 10000 || third_maximum > 10000){//3000 idi
		found_flag = 1;
		//Clear detection width*height array after command is sent
		for (c = 0; c<detection_count; c++)
		{
			detections_wh[c] = 0;
		}
	}
	second_last_maximum = second_maximum;
	last_maximum = maximum;

	detection_count = 0;

        // cout << endl << endl;
        //imshow(thresholded_window_name, edges);
        //imshow(contours_window_name, drawing);

	//Do things since object found
	if (found_flag == 1)
	{
	         printf("OBJECT FOUND\n");
		 ofstream myfile;
		 myfile.open("/var/www/html/ethernet_command_to_xmos.inc");
		 myfile << "S00A00FE";
		 myfile.close();
	         found_flag = 0;
	 }
	    
	 counter++;


    }
    //destroyWindow(output_window_name);
    //destroyWindow(thresholded_window_name);
    //destroyWindow(grayscale_window_name);
    //destroyWindow(contours_window_name);


    //Close raspicam
    //cap.release(); --> In webcam
    Camera.release();

    
    return 0;

}
