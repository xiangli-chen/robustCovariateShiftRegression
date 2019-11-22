function rr_plotLogLoss(tarData)
numData=size(tarData.input,2);
x = 1:numData;
weight = tarData.weight;
robustDEPdf = -log(tarData.robustDEPdf);
robustKLDPdf = -log(tarData.robustKLDPdf);
basePdf = -log(tarData.basePdf);
lsPdf = -log(tarData.lsPdf);
lsBAIWPdf = -log(tarData.lsBAIWPdf);
lsIWPdf = -log(tarData.lsIWPdf);
lsBPdf = -log(tarData.lsBPdf);

subplot(2,1,1)
plot(x,weight);

subplot(2,1,2)

DELine = plot(x,robustDEPdf,'b','lineWidth',1,'Marker','.','MarkerSize',1);
hold on;
KDLLine = plot(x,robustKLDPdf,'r','lineWidth',1,'Marker','.','MarkerSize',1);
hold on;
BSLine = plot(x,basePdf,'g','lineWidth',1,'Marker','.','MarkerSize',1);
hold on;
LSLine = plot(x,lsPdf,'y','lineWidth',1,'Marker','.','MarkerSize',1);
hold on;
BAIWLine = plot(x,lsBAIWPdf,'c','lineWidth',1,'Marker','.','MarkerSize',1);
hold on;
IWLine = plot(x,lsIWPdf,'m','lineWidth',1,'Marker','.','MarkerSize',1);
hold on;
BLLine = plot(x,lsBPdf,'Color',[0.8,0.8,0.8],'lineWidth',1,'Marker','.','MarkerSize',1);
hold off;

h_legend = legend('DE','KLD','BS','LS','AIWLS','IWLS','BL');
set(h_legend,'FontSize',12);