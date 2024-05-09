# AWS Batch Video Super-Resolution powered by the Intel® Library for Video Super Resolution

<!--TOC-->

- [Introduction](#introduction)
- [Disclaimer And Data Privacy Notice](#disclaimer-and-data-privacy-notice)
- [Architecture](#architecture)
- [Deploy the solution with AWS Cloudformation](#deploy-using-cloudformation)
- [Extend the solution](#extend-the-solution)
- [Cost](#cost)
- [Clean up](#clean-up)
- [References](#References)

<!--TOC-->

## Introduction
Implementing Super-resolution based on the enhanced RAISR algorithm utilizing Intel AVX-512 requires AWS-specific instance types, such as c5.2xlarge, c6i.2xlarge, and c7i.2xlarge. We leverage [AWS Batch](https://aws.amazon.com/batch/) to compute jobs and automate the entire pipeline rather than dealing with all the underlying infrastructure, including start and stop instances. We also automate the ingress and egress workflow to trigger each job based on an S3 bucket event. Therefore,  AWS customers interested in using the benefits of the enhanced RAISR algorithm for super-resolution can continue focusing on the ABR transcoding pipeline and adapt their existing workflow to leverage AWS Batch as a preprocessing stage.
The first step is to create a compute environment in AWS Batch, where CPU requirements are defined, including the type of EC2 instance allowed. The second step regards creating a job queue associated with the proper computing environment. Each job submitted in this queue will be executed using the specific EC2 instances. The third step involves the definition of a job. At this point, it is necessary to have a container registered in the AWS Elastic Container Register [ECR](https://aws.amazon.com/ecs/). Building the container is further detailed in section [Extend the solution](#extend-the-solution). The container includes installing the Intel Library for VSR, open-source ffmpeg tool, and AWS CLI to perform API calls to S3 buckets. Once the job is properly defined (image registered in ECR), Jobs can start being submitted into the queue.

## Disclaimer And Data Privacy Notice

When you deploy this solution, scripts will download different packages with different licenses from various sources. These sources are not controlled by the developer of this script. Additionally, this script can create a non-free and un-redistributable binary. By deploying and using this solution, you are fully aware of this.

## Architecture


![Architecture](architecture.png)

## Deploy using cloudformation
Bellow are described the steps to deploy the proposed solution:
1. Download [template.yml](https://github.com/aws-samples/video-super-resolution-tool/blob/main/template.yml)
2. Go to CloudFormation from AWS Console  to create a new stack using  template.yml
3. The template allows definition of next parameters :
    * Memory :  Memory associated to the job definition. This value can be overwritten when jobs are submitted
    * Subnet:  AWS Batch will deploy proper EC2 instance types ( c5.2xlarge, c6i.2xlarge, and c7i.2xlarge) in selected customer subnet with Internet access
    * VPCName: Existing VPC where selected Subnet is associated
    * VSRImage:  This field use an existing public image but customer can create their own image and insert the URL here. Instructions to create custom image are found [here](#extend-the-solution)
    * VCPU: VCPU associated to the job definition. This value can be overwritten when jobs are submitted
4. After deploying, verify that two s3 bucket has been created. They start with vsr-input and vsr-output
5. Upload a SD file to vsr-input-xxxx-{region-name} bucket
6. Go to Batch from AWS console and validate a new queue (queue-vsr) and compute environment (VideoSuperResolution) have been created
7. Inside Jobs (left-side) click on "submit  a new job, selecting the proper job definition (vsr-jobDefiniton-xxxx) and queue (queue-vsr)
8. In the next screen,  click  on "Load from job definition" and modify the name of input and output files
9. Review and submit the job and wait until Status transitions to runnable and then Succeeded
10. Go to output S3 bucket (vsr-output-xxxx-{region-name}) to validate a Super-resolution file has been created and uploaded to S3 automatically
11. Compare side-by-side subjective visual quality using open-source tool [compare-video](https://github.com/pixop/video-compare)
    
## Extend the solution 

During deployment using Cloudformation template,  a parameter (VSRImage) is requested. You can use the default value or create your own container using [Intel® Library for Video Super Resolution](https://github.com/OpenVisualCloud/Video-Super-Resolution-Library) project as baseline.  In addition you can make adjustments to ffmpeg libraries (i.e. adding x264, x265, jpeg-xs libraries). In this implementation is also included aws-cli with S3 read/write capabilities.  All those changes are detailed in Dockerfile.

### Prerequisites
   - Ubuntu machine 22.04 to build a container
   - Docker installed in Ubuntu 22.04
   - AWS [ECR](https://aws.amazon.com/ecr/) repository already created, instructions can be found [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html#cli-create-repository)

### Building custom container   
   - From Ubuntu machine clone [Intel® Library for Video Super Resolution](https://github.com/OpenVisualCloud/Video-Super-Resolution-Library)
   - copy  [main.sh](https://github.com/aws-samples/video-super-resolution-tool/edit/main/container/main.sh) and [Dockerfile.2204](https://github.com/aws-samples/video-super-resolution-tool/edit/main/container/Dockerfile.2204) into Video-Super-Resolution-Library folder
   - Download and unzip [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) inside Video-Super-Resolution-Library folder
   - Inside Video-Super-Resolution-Library folder execute `sudo docker build -f Dockerfile.2204 -t vsr-intel`
   - Follow ECR instructions to push a container to an existing repository. Instruction can be found [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html#cli-push-image)


## Cost

AWS Batch optimizes compute costs by paying only for used resources. Using Spot instances leverages unused EC2 capacity for significant savings over On-Demand instances. Benchmark different instance types and sizes to find the optimal workload configuration.

## Clean up

To prevent unwanted charges after evaluating this solution, delete created resources by:

1. Delete all objects in the Amazon S3 bucket used for testing. You can remove these objects from the S3 console by selecting all objects and clicking "Delete."
2. Delete the AWS Cloudformation stack from AWS Console
3. Verify that all resources have been removed by checking the AWS console. This ensures no resources are accidentally left running, which would lead to unexpected charges.

## References
1. [Intel® Library for Video Super Resolution](https://github.com/OpenVisualCloud/Video-Super-Resolution-Library)
2. [ffmpeg](https://ffmpeg.org)
3. [Whitepaper short-version](https://dl.acm.org/doi/10.1145/3638036.3640290)
4. [Whitepaper long-version] (https://www.intel.com/content/www/us/en/content-details/820769/aws-compute-video-super-resolution-powered-by-the-intel-library-for-video-super-resolution.html)


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

