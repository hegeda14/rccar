#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>

#define PICTURE_MIDPOINT 240
#define LEFT 1
#define MID  2
#define RIGHT 3
#define SLOW 4
#define STOP 5

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
int u_h=0;//0;  //0
int u_s=102;//134;//120; //197
int u_v=220;//212;//120; //189
int d_h=256;//256; //9
int d_s=256; //256
int d_v=256; //256

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
int detection_count = 0;

int openings_w[10];
int openings_h[10];
int openings_x[10];
int openings_y[10];
int opening_count = 0;

void canny(int, void*){}

int main(int argc, char** argv)
{

    namedWindow(output_window_name, CV_WINDOW_AUTOSIZE);
    namedWindow(grayscale_window_name, 100);
    namedWindow(thresholded_window_name, 100);
    namedWindow(contours_window_name, 100);

    moveWindow(grayscale_window_name, 20,20);
    moveWindow(thresholded_window_name, 20, 250);
    moveWindow(contours_window_name, 20, 600);


    vector<int> compression_params;
    compression_params.push_back(CV_IMWRITE_JPEG_QUALITY);
    compression_params.push_back(100);

    VideoCapture cap(0);
    if(!cap.isOpened())  // check if we succeeded
       return -1;

    Mat frame;
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

    int cmd = MID;
    int speed = STOP;

    createTrackbar("canny low Threshold: ", output_window_name, &canny_lowthreshold, max_val, canny);
    createTrackbar("canny high Threshold: ", output_window_name, &canny_highthreshold, max_val, canny);
    //createTrackbar("height: ", output_window_name, &height_bound, float_max_val, canny);
    //createTrackbar("width: ", output_window_name, &width_bound, float_max_val, canny);
    createTrackbar("solidity: ", output_window_name, &solidity_bound, float_max_val, canny);
    //
    createTrackbar("Up AspectRatio: ", output_window_name, &up_aspectRatio, aspect_max_val, canny);
    createTrackbar("Down AspectRatio: ", output_window_name, &down_aspectRatio, aspect_max_val, canny);
     createTrackbar("Up H: ", output_window_name, &u_h, color_max_val, canny);
     createTrackbar("Up S: ", output_window_name, &u_s, color_max_val, canny);
     createTrackbar("Up v: ", output_window_name, &u_v, color_max_val, canny);
     createTrackbar("Down H: ", output_window_name, &d_h, color_max_val, canny);
     createTrackbar("Down S: ", output_window_name, &d_s, color_max_val, canny);
     createTrackbar("Down v: ", output_window_name, &d_v, color_max_val, canny);


    while(1){

        cap >> frame;
	printf("Starting...\n");
        key = waitKey(10);
        //cout <<(int) char(key) << endl;
        if(char(key) == 27){
            break;
        }
        // if(char(key) == 10){

            imgHsv.create(frame.size(), frame.type());
            cvtColor(frame, imgHsv, CV_BGR2HSV);

            inRange(imgHsv, Scalar(u_h, u_s, u_v), Scalar(d_h, d_s, d_v), imgRedThresh);
            //??Eklendi
               inRange(imgHsv, Scalar(w_u_h, w_u_s, w_u_v), Scalar(w_d_h, w_d_s, w_d_v), imgWhiteThresh);
	       add(imgRedThresh, imgWhiteThresh, imgResultingThresh);
	    //--
            //converting the original image into grayscale
            imgGrayScale.create(frame.size(), frame.type());
            cvtColor(frame, imgGrayScale, CV_BGR2GRAY);
            bitwise_and(imgRedThresh, imgGrayScale, imgGrayScale);//??Degistirildi bitwise_and(imgResultingThresh, imgGrayScale, imgGrayScale);

            // Floodfill from point (0, 0)
            Mat im_floodfill = imgGrayScale.clone();
            floodFill(im_floodfill, cv::Point(0,0), Scalar(255));

            // Invert floodfilled image
            Mat im_floodfill_inv;
            bitwise_not(im_floodfill, im_floodfill_inv);

            // Combine the two images to get the foreground.
            imgGrayScale = (imgGrayScale | im_floodfill_inv);

            GaussianBlur(imgGrayScale, imgGrayScale, Size(7,7), 1.5, 1.5);

            imshow(grayscale_window_name, imgGrayScale);

            edges.create(imgGrayScale.size(), imgGrayScale.type());
            Canny(imgGrayScale, edges, canny_lowthreshold, canny_highthreshold, 3);

            findContours(edges, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0,0));
            Mat drawing = Mat::zeros(edges.size(), CV_8UC3);

	    //For all contours
            for(int i=0 ; i<contours.size() ; i++){
              contPeri = arcLength(contours.at(i), true);
              approxPolyDP(contours.at(i), approx,  0.01 * contPeri, true);

              //if(approx.size()>=7 && approx.size()<=9){
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

                 if(bBox.width > width_bound && bBox.height > height_bound && solidity > solidity_bound/10/**/ && aspectRatio >= down_aspectRatio/10 && aspectRatio <= up_aspectRatio/10)
                //if(bBox.width > width_bound && bBox.height > height_bound /*&& solidity > solidity_bound/10*/)
                {
		  //Find detections
		  printf("%d\t%d\n",bBox.width, bBox.height);
		  detections_x[detection_count] = bBox.x;
		  detections_y[detection_count] = bBox.y;
		  detections_w[detection_count] = bBox.width;
		  detections_h[detection_count] = bBox.height;
		  detection_count = detection_count + 1;


                  Scalar color = Scalar(rng.uniform(0,255), rng.uniform(0,255), rng.uniform(0,255));
                  drawContours(drawing, tempVecCont, 0, color, 2, 8, hierarchy, 0, Point());
		  rectangle( drawing, Point( bBox.x, bBox.y), Point( bBox.x+bBox.width, bBox.y+bBox.height), Scalar( 0, 55, 255 ), +4, 4 );
                }
              //}

            }
	    //Search every detection pair to see if there is a cone
	    for(int k=0; k < detection_count; k++)
		for(int n=0; n < detection_count; n++)
		{
			if(detections_x[k]>detections_x[n] && detections_y[k] < detections_y[n] && detections_h[k] < detections_h[n] && detections_w[k] < detections_w[n])
			{
				rectangle( drawing, Point( detections_x[n], detections_y[n]),  Point( detections_x[n]+detections_w[n], detections_y[n]+detections_h[n]), Scalar( 255, 55, 0 ), +7, 4 );
				  openings_x[opening_count] = detections_x[n];
				  openings_y[opening_count] = detections_y[n];
				  openings_w[opening_count] = detections_w[n];
				  openings_h[opening_count] = detections_h[n];
				opening_count++;
				//printf("oc=%d",opening_count);// diagnose later

				
			}
		}

	    //Select 2 detections with an opening
   	    for(int k=0; k < opening_count; k++)
		for(int n=0; n < opening_count; n++)
		{
			if(openings_x[k]-openings_x[n] > PICTURE_MIDPOINT - 10)
			{
				//Orta aciklik
				opening_length = openings_x[n]+openings_w[n]-openings_x[k];
				opening_midpoint = openings_x[k] + ((openings_x[n]+openings_w[n])/2);
				printf("om = %d\n",opening_midpoint);
				if (opening_midpoint > PICTURE_MIDPOINT)
				{
					cmd = RIGHT;
					speed = SLOW;
				}
				else
					if(opening_midpoint < PICTURE_MIDPOINT)
					{
						cmd = LEFT;
						speed = SLOW;
					}
				else
				{
					cmd = MID;
					speed = SLOW;
				}
			}
			else
			{
				cmd = MID;
				speed = STOP;
			}
		}
	    printf("cmd=%d   speed=%d\n", cmd, speed);
	    //printf("midpointimg = %d\n", imgRedThresh.rows);


	    detection_count = 0;
	    opening_count = 0;
            // cout << endl << endl;
            imshow(thresholded_window_name, edges);
            imshow(contours_window_name, drawing);

            //Subimage almak icin
	    //cv::Mat subImg = drawing(cv::Range(0, 100), cv::Range(0, 100));
	    //imshow("My work", subImg);
	    //----


            // imshow(thresholded_window_name, imgGrayScale);
            // imshow(contours_window_name, imgRedThresh);

        // }
        imshow(output_window_name, frame);

    }
    destroyWindow(output_window_name);
    destroyWindow(thresholded_window_name);
    destroyWindow(grayscale_window_name);
    destroyWindow(contours_window_name);
    cap.release();

    return 0;

}
