# GetPulse---Matlab-Implementation
Matlab Implementation to predict the pulse rate of a subject based on change of colour of skin due to blood flow.
<br>

Steps :
<br>
<pre>
    1. Video Aquisition<br>
    2. ROI Selection<br>
    3. Band-Pass Filtering (2nd Order Butterworth Filter)<br>
    4. Thresholding of desired pulse range<br>
    5. Sliding Window (Repeated for frames in each 6 Seconds)<br><pre>
          a.  FFT<br>
          b.  Peak Detection <br>
          c.  Smoothing <br>
          </pre>   
</pre>
