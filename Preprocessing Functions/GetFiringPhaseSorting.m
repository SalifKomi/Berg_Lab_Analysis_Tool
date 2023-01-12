function SortingIndices = GetFiringPhaseSorting(FiringMatrix,Ops,varargin)
    Method = 'Correlation';
    Source = sum(FiringMatrix,2);
    for ii = 1:2:length(varargin)
        switch(varargin{ii})
            case 'Source'
                Source = varargin{ii+1};
            case 'Method'
                Method = varargin{ii+1};
        end
    end

    switch Method 
        case 'Correlation'
           % whole = FiringMatrix(:,15);
            whole = Source; 
            scores = [];
            for n = 1:size(FiringMatrix,2)
                [C,L] = xcorr(whole,FiringMatrix(:,n));
                [~,loc] = max(C);
                scores = [scores L(loc)];
            end
            
            [autocor,~] = xcorr(whole);
            [~,lcsh] = findpeaks(autocor);
            short = mean(diff(lcsh));

            scores =rem((scores.*2*pi)./short,2*pi);
            
            [~,CorrSorting] =  sort(scores,'ascend');
%             SortedFiring = FiringMatrix(:,CorrSorting);
            SortingIndices = CorrSorting;
            
        case 'Coherence'                
            %% Get Series with most rythmical activity
            Cohr = [];
            for ii = 1:size(FiringMatrix,2)
                [~,Coh,~] = ComputeCoherence(Source,FiringMatrix(:,ii),10,1/Ops.fs,5);
                Cohr = [Cohr Coh];
            end
            [~,CohSorting] =  sort(Cohr,'ascend');
            SortingIndices = CohSorting;
    end
end
