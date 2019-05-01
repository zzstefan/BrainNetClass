function L=computeLap(X)
% Compute graph Laplacian

optL=[];
optL.NeighborMode='KNN';
optL.k=5;
optL.WeightMode='Cosine';   % 'Cosine' or 'HeatKernel'
optL.t=1;
L=constructW(X,optL);
