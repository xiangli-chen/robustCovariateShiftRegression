function rr_plotSrcTarData(srcData,tarData)
srcInput = srcData.input;
srcOutput = srcData.output;
tarInput = tarData.input;
tarOutput = tarData.output;
numAttr = size(srcInput,1)+1;
numRow = floor(sqrt(numAttr));
numCol = numRow;
while (numRow*numCol<numAttr)
    numCol = numCol+1;
end
figure;
for i = 1:numAttr-1
    subplot(numRow,numCol,i);
    plot(srcInput(i,:),srcOutput,'b.',...
        tarInput(i,:),tarOutput,'r.');
end
subplot(numRow,numCol,numAttr);
    plot(srcOutput,srcOutput,'b.',...
        tarOutput,tarOutput,'r.');