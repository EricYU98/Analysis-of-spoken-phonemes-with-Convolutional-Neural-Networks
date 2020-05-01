clear all
clc
close all

XTrain={};
YTrain={};




%% load female speaker wav samples
cd 'C:\Users\Eric\Desktop\Project\Data\wav_fsew'

filedir = dir('*.wav');           %list the current folder content for .wav file
Y_female = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
FS_female = Y_female;    %pre-allocate FS in memory (edit from @ Werner)

number =length(filedir);

for i = 1:200       %loop through the file names

    %read the .wav file and store them in cell arrays
    [Y_female{1,i}, FS_female{1,i}] = audioread(filedir(i).name);  

end


%% load female speaker lab samples
cd 'C:\Users\Eric\Desktop\Project\Data\lab_fsew'

filedir = dir('*.lab');   %list the current folder content for .wav file

lab_female = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
num_of_phonemes_female=ones(1,length(filedir));
for i = 1:200   %loop through the file names

    %read the .lab file and store them in cell arrays
    [Phonemes,numPhonemes] = convert_LAB_to_Phonemes(filedir(i).name);  
    lab_female{1,i}=Phonemes;
    num_of_phonemes_female(i)=numPhonemes;

end

%% build the training set
for i= 1:200
    Y_female{1,i}=Y_female{1,i}(1:lab_female{1,i}{num_of_phonemes_female(i),2}*16000);
    XTrain=[XTrain,Y_female{1,i}'];
    
    
    label_sequence={};
    for j=1:num_of_phonemes_female(i)
        for k= 1: (lab_female{1,i}{j,2}-lab_female{1,i}{j,1})*16000
            label_sequence=[label_sequence,lab_female{1,i}{j,3}];
        end
    
    end
     if length(label_sequence) > length(Y_female{1,i}')
            label_sequence=label_sequence(1:length(Y_female{1,i}'));
     else
            Y_female{1,i}=Y_female{1,i}(1:length(label_sequence));
            XTrain{i}=Y_female{1,i}';
     end
    state = categorical(label_sequence);
    YTrain{i}=state;
    
    
end
XTrain=XTrain'
YTrain=YTrain'

%% Visualize one training sequence in a plot
X = XTrain{1};
classes = categories(YTrain{1});
figure
for j = 1:numel(classes)
    label = classes(j);
    idx = find(YTrain{1} == label);
    hold on
    plot(idx,X(idx))
end
hold off

xlabel("Time Step")
ylabel("Acceleration")
title("Training Sequence 1, Feature 1")
legend(classes,'Location','northwest')

%% Define LSTM Network Architecture
numFeatures = 1;
numHiddenUnits = 200;
numClasses = 46;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];
%% Specify the training options.
options = trainingOptions('adam', ...
    'MaxEpochs',1, ...
    'MiniBatchSize',10,...
    'GradientThreshold',2, ...
    'Verbose',0, ...
    'Plots','training-progress');

%% Train the LSTM 
net = trainNetwork(XTrain',YTrain',layers,options);

%% save the network
save('lstm_female', 'net');
%% convert lab to matlab cell
function [Phonemes,numPhonemes] = convert_LAB_to_Phonemes(LAB)

% Input may be a cell with the labelled phonemes or just the file from which these
% must be read
if ~isa(LAB,'cell')
    LAB = importdata(LAB,' ');
end
    %% Interpret Labelled Phonemes
    % Read the numLines    
    numPhonemes             = size(LAB,1);
    Phonemes{numPhonemes,3}     = '';
    for k=1:numPhonemes
        % Each line is a {start end phoneme}
        currLine            = LAB{k};
        placesSpace         = strfind(currLine,' ');
        Phonemes{k,1}           = str2double(currLine(1:placesSpace(1)-1));
        Phonemes{k,2}           = str2double(currLine(placesSpace(1)+1:placesSpace(2)-1));
        Phonemes{k,3}           = (currLine(placesSpace(2)+1:end));
    end
end