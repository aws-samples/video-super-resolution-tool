#  $1 :  source bucket
#  $2 :  source file name
#  $3 :  destination bucket
#  $4 :  destination file name
#  Example: ./main.sh 's3://vsr-input-365168541851-us-east-1-9489e2b0 'input-low-resolution.ts' 's3://vsr-output-365168541851-us-east-1-9489e2b0' 'output-high-resolution.ts'
aws s3 cp $1/$2 ./files
./ffmpeg -i ./files/$2  -vf "raisr=threadcount=20:passes=2:filterfolder=filters_2x/filters_highres" -pix_fmt yuv420p  -c:v libx264 -crf 17 -y  ./files/$4
aws s3  cp ./files/$4  $3/$4
rm -rf ./files/$2
rm -rf ./files/$4
