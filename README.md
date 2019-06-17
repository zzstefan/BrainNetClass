# BrainNetClass
We are glad to announce that our new Brain Network Construction & Classification toolbox, BrainNetClass-v1.0, has been released on Github (https://github.com/zzstefan/BrainNetClass). It was developed by IDEA (Image Display, Enhancement and Analysis Laboratory) at the University of North Carolina at Chapel Hill. 

It is a Matlab-based, open-coded, fully automated brain functional connectivity network-based disease classification toolbox with user-friendly GUI that automatically conducts functional network construction, network feature extraction and selection, parameter optimization, classification, model validation, and result demonstration. It was designed to help neuroscientists, doctors, and researchers in other fields who have limited coding and machine learning knowledge to easily and correctly work on brain functional connectomics building with state-of-the-art algorithms [1-8] and conduct rigorous individualized disease diagnosis or other classification tasks. It is hoped that this toolbox could be of help in standardization the methodology and boost reproducibility, generalizability, and interpretability of the network-based classification. 

Specifically, BrainNetClass-v1.0 provides abundant algorithms for brain functional network construction, including those recently developed for high-order functional networks [1,4-6,8] and those utilizing sparse representation with advanced, biologically meaningful constraints for robust and consistent network construction [2,3,7]. What’s more, it provides standard yet rigorous network-based classification with choices of feature extraction, feature reduction, cross-validation, and performance evaluation. Importantly, it goes further from providing simple metrics (e.g., accuracy) to a battery of more comprehensive results (e.g., receiver operating characteristic curve, parameter sensitivity test, model robustness test, contributing discriminative features, and a full log of results for a hassle-free report). 

With a simple configuration on a GUI interface, all these results and reports are just a few clicks away. All the processes will be automatically performed and results will be saved for users to evaluate the model and interpret the findings. More importantly, the model will be saved for future use on newly acquired data to perform a quick classification or diagnosis. 

For details, please see the manual. Exemplary toy data are provided for a quick walkthrough. Please contact Zhen Zhou (zzstefan@email.unc.edu), Han Zhang (hanzhang@med.unc.edu), and Dinggang Shen (dgshen@med.unc.edu) for any issues and suggestions. Your feedback is more than welcomed to help us improve it. If you feel it is helpful to your research, please cite the following papers.

BrainNetClass-v1.0 uses libsvm-3.23 and SLEP-4.1 toolboxes. We would like to thank Xiaobo Chen, Yu Zhang, Lishan Qiao, Renping Yu for their contributions. It was supported by the NIH grants (EB022880, AG041721, AG049371, and AG042599). 


References \
[1] Chen, X., Zhang, H., Gao, Y., Wee, C.Y., Li, G., Shen, D., Alzheimer's Disease Neuroimaging, I., 2016. High-order resting-state functional connectivity network for MCI classification. Hum Brain Mapp 37, 3282-3296. \
[2] Qiao, L., Zhang, H., Kim, M., Teng, S., Zhang, L., Shen, D., 2016. Estimating functional brain networks by incorporating a modularity prior. NeuroImage 141, 399-407. \
[3] Zhang, Y., Zhang, H., Chen, X., Liu, M., Zhu, X., Lee, S.-W., Shen, D., 2019. Strength and Similarity Guided Group-level Brain Functional Network Construction for MCI Diagnosis. Pattern Recognition, 88, 421-430. \
[4] Zhang, H., Chen, X., Zhang, Y., Shen, D., 2017. Test-retest reliability of “high-order” functional connectivity in young healthy adults. Frontiers in Neuroscience, 11:439. \
[5] Zhang, Y., Zhang, H., Chen, X., Lee, S.-W., Shen, D., 2017. Hybrid High-order Functional Connectivity Networks Using Resting-state Functional MRI for Mild Cognitive Impairment Diagnosis, Scientific Reports, 7: 6530. \
[6] Chen, X., Zhang, H., Shen, D., 2017. Hierarchical High-Order Functional Connectivity Networks and Selective Feature Fusion for MCI Classification. Neuroinformatics, 15(3):271-284. \
[7] Yu, R., Zhang, H., An, L., Chen, X., Wei, Z., Shen, D., 2017. Connectivity strength-weighted sparse group representation-based brain network construction for MCI classification. Human Brain Mapping, 38(5): 2370-2383. \
[8] Zhang, H., Chen, X., Shi, F., Li, G., Kim, M., Giannakopoulos, P., Haller, S., Shen, D., 2016. Topographic Information based High-Order Functional Connectivity and its Application in Abnormality Detection for Mild Cognitive Impairment, Journal of Alzheimer's Disease, 54(3): 1095-1112. \
[9] To be published.
