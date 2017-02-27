#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <pigpio.h>

#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#include <raspicam/raspicam.h>
#include <raspicam/raspicam_cv.h>
#include <ctime>

#include <fstream>

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

int portno = 15534;

int first_time_cmp = 1;

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

int connect_flag = 0; //Flag for TCP connection.
int send_flag = 0;

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

#define CLOSEBUTTON_PIN 21
void SetupGpio (void)
{
	gpioInitialise();
	gpioSetMode (CLOSEBUTTON_PIN, PI_INPUT);
}


void SafeShutdownCheckGpio(void)
{
	printf("%d\n", gpioRead(CLOSEBUTTON_PIN));
	if(gpioRead(CLOSEBUTTON_PIN)!=1)
	{
		//Exit system safely
		system("halt");
	}
}

int main(int argc, char *argv[])
{

    //TCP Connection "sudo ./TrafficConeDetection connect"
    if(argc>1 ){
    	connect_flag = 1;
    }else{
        connect_flag = 0;
    }

    int sockfd, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;

    char buffer[256];
    char msg[10]="S00A50FE\r";
    
    //SetupGpio();

    /*if(connect_flag == 1)
    {
	    sockfd = socket(AF_INET, SOCK_STREAM, 0);
	    if (sockfd < 0) 
		error("ERROR opening socket");
	    server = gethostbyname("192.168.20.48");
	    if (server == NULL) {
		fprintf(stderr,"ERROR, no such host\n");
		exit(0);
	    }
	    bzero((char *) &serv_addr, sizeof(serv_addr));
	    serv_addr.sin_family = AF_INET;
	    bcopy((char *)server->h_addr, 
		 (char *)&serv_addr.sin_addr.s_addr,
		 server->h_length);
	    serv_addr.sin_port = htons(portno);
	    if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) 
		error("ERROR connecting");
    }*/


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

    int cmd = MID;
    int speed = STOP;

  double maximum ;
  double second_maximum ;
  double third_maximum;
  int maximum_idx ;
  int second_maximum_idx ;
  int third_maximum_idx;
  double second_last_maximum;
  double last_maximum;

    
int counter = 0;
int counter_max = 1;
//createTrackbar("canny low Threshold: ", output_window_name, &canny_lowthreshold, max_val, canny);
//createTrackbar("canny high Threshold: ", output_window_name, &canny_highthreshold, max_val, canny);
//   createTrackbar("height: ", output_window_name, &height_bound, float_max_val, canny);
//  createTrackbar("width: ", output_window_name, &width_bound, float_max_val, canny);
//  createTrackbar("solidity: ", output_window_name, &solidity_bound, float_max_val, canny);
    //
//  createTrackbar("Up AspectRatio: ", output_window_name, &up_aspectRatio, aspect_max_val, canny);
//  createTrackbar("Down AspectRatio: ", output_window_name, &down_aspectRatio, aspect_max_val, canny);
//createTrackbar("Up H: ", output_window_name, &u_h, color_max_val, canny);
//createTrackbar("Up S: ", output_window_name, &u_s, color_max_val, canny);
//createTrackbar("Up v: ", output_window_name, &u_v, color_max_val, canny);
//createTrackbar("Down H: ", output_window_name, &d_h, color_max_val, canny);
//createTrackbar("Down S: ", output_window_name, &d_s, color_max_val, canny);
//createTrackbar("Down v: ", output_window_name, &d_v, color_max_val, canny);


while(1){
        //SafeShutdownCheckGpio();

        //Capture image with Raspicam_CV
        Camera.grab();
        Camera.retrieve(frame);  //cap >> frame
	
	//cv::imwrite("raspicam_img.jpg", frame);


      
	printf("Starting...\n");
        //key = waitKey(10);
        //cout <<(int) char(key) << endl;
        //if(char(key) == 27){
        //    break;
        //}
        // if(char(key) == 10){

	    frameRGB.create(frame.size(), frame.type());
	    cvtColor(frame, frameRGB, CV_BGR2RGB);
	
            imgHsv.create(frameRGB.size(), frameRGB.type());
            cvtColor(frameRGB, imgHsv, CV_RGB2HSV);//HSV

	    //cv::imwrite("raspicam_img.jpg", imgHsv);

            inRange(imgHsv, Scalar(u_h, u_s, u_v), Scalar(d_h, d_s, d_v), imgRedThresh);
            //??Eklendi
               //inRange(imgHsv, Scalar(w_u_h, w_u_s, w_u_v), Scalar(w_d_h, w_d_s, w_d_v), imgWhiteThresh);
	       //add(imgRedThresh, imgWhiteThresh, imgResultingThresh);
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

            //imshow(grayscale_window_name, imgGrayScale);

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

                 if(bBox.width > width_bound && bBox.height > height_bound && solidity > solidity_bound/10/*&& aspectRatio >= down_aspectRatio/10 && aspectRatio <= up_aspectRatio/10*/ )
                //if(bBox.width > width_bound && bBox.height > height_bound /*&& solidity > solidity_bound/10*/)
                {
		  //Find detections
		  //printf("%d\t%d\n",bBox.width, bBox.height);
		  detections_x[detection_count] = bBox.x;
		  detections_y[detection_count] = bBox.y;
		  detections_w[detection_count] = bBox.width;
		  detections_h[detection_count] = bBox.height;
		  detections_wh[detection_count] = bBox.width*bBox.height;
		  detection_count = detection_count + 1;


                  //Scalar color = Scalar(rng.uniform(0,255), rng.uniform(0,255), rng.uniform(0,255));
                  //drawContours(drawing, tempVecCont, 0, color, 2, 8, hierarchy, 0, Point());
		  //rectangle( drawing, Point( bBox.x, bBox.y), Point( bBox.x+bBox.width, bBox.y+bBox.height), Scalar( 0, 55, 255 ), +4, 4 );
                }
              //}

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

	  
	  printf("mid = %d\n",opening_midpoint);
          printf("maximum=%f\n",maximum);
	  if(maximum > 10000 || second_maximum > 10000 || third_maximum > 10000){//3000 idi
		cmd = LEFT;
		speed = STOP;
		send_flag = 1;
		//Clear detection width*height array after command is sent
		for (c = 0; c<detection_count; c++)
		{
			detections_wh[c] = 0;
		}
	}else{
	  
		
	}
	second_last_maximum = second_maximum;
	last_maximum = maximum;
	    //Search every detection pair to see if there is a cone
	    /*for(int k=0; k < detection_count; k++)
		for(int n=0; n < detection_count; n++)
		{
			if(detections_x[k]>detections_x[n] && detections_y[k] < detections_y[n] && detections_h[k] < detections_h[n] && detections_w[k] < detections_w[n])
			{
				rectangle( drawing, Point( detections_x[n], detections_y[n]),  Point( detections_x[n]+detections_w[n], detections_y[n]+detections_h[n]), Scalar( 255, 55, 0 ), +7, 4 );        printf("%d", compareOpenings(opening_count, opening_count-1, first_time_cmp));
				 if(compareOpenings(opening_count, opening_count-1, first_time_cmp) != 1) {
					  openings_x[opening_count] = detections_x[n];
					  openings_y[opening_count] = detections_y[n];
					  openings_w[opening_count] = detections_w[n];
					  openings_h[opening_count] = detections_h[n];
					  opening_count++;
					  printf("oc=%d",opening_count);// diagnose later
					  first_time_cmp = 0;
				}
  				
				
			}
		}*/

	    //Select 2 detections with an opening
   	    /*for(int k=0; k < opening_count; k++)
		for(int n=0; n < opening_count; n++)
		{
			if(abs(openings_x[k]-openings_x[n]) > PICTURE_MIDPOINT - 10)
			{
				//Orta aciklik
				opening_length = abs(openings_x[n]+openings_w[n]-openings_x[k]);
				opening_midpoint = openings_x[k] + ((openings_x[n]+openings_w[n])/2);
				printf("ol = %d\n",opening_length);
				printf("om = %d\n",opening_midpoint);
				printf("pm = %d\n",PICTURE_MIDPOINT);
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
		}*/

	    printf("cmd=%d   speed=%d\n", cmd, speed);
	    //printf("midpointimg = %d\n", imgRedThresh.rows);


	    detection_count = 0;
	    opening_count = 0;
            // cout << endl << endl;
            //imshow(thresholded_window_name, edges);
            //imshow(contours_window_name, drawing);


	    //TCP Writing to Socket & Command construction
	    if(MID == cmd && SLOW == speed)
	    {
		//msg = "S15A50FE";
		msg[0]='S';
		msg[1]='1';
		msg[2]='5';
		msg[3]='A';
		msg[4]='5';
		msg[5]='0';
		msg[6]='F';
		msg[7]='E';
	    }
	    else if(LEFT == cmd && SLOW == speed)
	    {
		//msg = "S15A20FE";
		msg[0]='S';
		msg[1]='1';
		msg[2]='5';
		msg[3]='A';
		msg[4]='2';
		msg[5]='0';
		msg[6]='F';
		msg[7]='E';
	    }
	    else if(RIGHT == cmd && SLOW == speed)
	    {
		//msg = "S15A80FE";
		msg[0]='S';
		msg[1]='1';
		msg[2]='5';
		msg[3]='A';
		msg[4]='8';
		msg[5]='0';
		msg[6]='F';
		msg[7]='E';
	    }
	    else if (LEFT == cmd && STOP == speed)
            {
  		msg[0]='S';
                msg[1]='0';
                msg[2]='0';
                msg[3]='A';
                msg[4]='0';
                msg[5]='0';
                msg[6]='F';
                msg[7]='E';

            }
	    else
	    {
		//msg = "S00A50FE";
		msg[0]='S';
		msg[1]='0';
		msg[2]='0';
		msg[3]='A';
		msg[4]='5';
		msg[5]='0';
		msg[6]='F';
		msg[7]='E';
	    }
	    if(/*counter == counter_max && */connect_flag == 1 && send_flag == 1)
            {
		    //bzero(buffer,256);
		    n = write(sockfd,msg,strlen(msg));
		    if (n < 0) {
			 
		 	error("ERROR writing to socket");
		 	close(sockfd);
			 
		    }
		    //bzero(buffer,256);
		    counter = 0;
		    send_flag = 0;
	    }

	    //Send by writing to file for ethernet_app_rpi to read.
	    if (send_flag == 1)
	    {
	         printf("OBJECT FOUND\n");
		 ofstream myfile;
		 myfile.open("/var/www/html/ethernet_command_to_xmos.inc");
		 myfile << "S00A00FE";
		 myfile.close();
	         send_flag = 0;
	    }
	    
	    counter++;
	    //usleep(100*1000);
            //Subimage almak icin
	    //cv::Mat subImg = drawing(cv::Range(0, 100), cv::Range(0, 100));
	    //imshow("My work", subImg);
	    //----


            //imshow(thresholded_window_name, imgGrayScale);
            //imshow(contours_window_name, imgRedThresh);

        // }
        //imshow(output_window_name, frameRGB);

    }
//destroyWindow(output_window_name);
//   destroyWindow(thresholded_window_name);
//  destroyWindow(grayscale_window_name);
//   destroyWindow(contours_window_name);


    //Close raspicam
    //cap.release(); --> In webcam
    Camera.release();

    
    return 0;

}
