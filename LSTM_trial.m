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

for i = 1:10        %loop through the file names

    %read the .wav file and store them in cell arrays
    [Y_female{1,i}, FS_female{1,i}] = audioread(filedir(i).name);  

end


%% load female speaker lab samples
cd 'C:\Users\Eric\Desktop\Project\Data\lab_fsew'

filedir = dir('*.lab');   %list the current folder content for .wav file

lab_female = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
num_of_phonemes_female=ones(1,length(filedir));
for i = 1:10   %loop through the file names

    %read the .lab file and store them in cell arrays
    [Phonemes,numPhonemes] = convert_LAB_to_Phonemes(filedir(i).name);  
    lab_female{1,i}=Phonemes;
    num_of_phonemes_female(i)=numPhonemes;

end


%% build the training set
for i= 1:10
    Y_female{1,i}=Y_female{1,i}(1:lab_female{1,i}{num_of_phonemes_female(i),2}*16000);
    XTrain=[XTrain,Y_female{1,i}'];
    
    
    label_sequence={};
    for j=1:num_of_phonemes_female(i)
        for k= 1: (lab_female{1,i}{j,2}-lab_female{1,i}{j,1})*16000
            label_sequence=[label_sequence,lab_female{1,i}{j,3}];
        end
        
        if length(label_sequence) > length(Y_female{1,i}')
            label_sequence=label_sequence(1:length(Y_female{1,i}'));
        else
            Y_female{1,i}=Y_female{1,i}(1:length(label_sequence));
            XTrain{i}=Y_female{1,i}';
        
        end
    
    end
    
    state = categorical(label_sequence);
    YTrain{i}=state;
    
    
end

size(YTrain{2})
size(XTrain{2})




%% create LSTM architecture

inLayer = sequenceInputLayer(1); % create input layer input size mean one row for each sample

lstm = bilstmLayer(100,'OutputMode','sequence'); % create BiLSTM layer

outLayers = [
    fullyConnectedLayer(46);
    softmaxLayer();
    classificationLayer()
    ];                        % create output layer 3 means three instruments, remain to be adjusted
layers = [inLayer;lstm;outLayers]; % combine layers
%% sets the training options used to train the LSTM

options = trainingOptions('adam', ...
    'MaxEpochs',250, ...
    'InitialLearnRate',0.005, ...
    'GradientThreshold',1, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'LearnRateDropPeriod',200,...
    'LearnRateSchedule','piecewise');

%% train an LSTM
net = trainNetwork(XTrain,YTrain,layers,options);

net

% %% classify test data
% testPred = classify(net,XTest)
% 
% %% Plot confusion matrix
% confusionchart(YTest,testPred)


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