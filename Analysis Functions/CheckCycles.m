function [C] = CheckCycles(C)
%% Padd the vector to the same size
if length(C.Start) ~= length(C.End)
      if (length(C.Start) > length(C.End))
          C.End = padarray(C.End,[0 (length(C.Start)-length(C.End)) + 1],'post');
          C.Start = padarray(C.Start,[0  1],'post');
      else 
          C.Start = padarray(C.Start,[0 (length(C.End)-length(C.Start)) + 1],'post');
          C.End = padarray(C.End,[0 1],'post');
      end   
end

%% Convert to logical vectors 
Start = logical(C.Start);
End = logical(C.End);

%% Find Unmached Events

IndR = find(xor(circshift(Start,1),End)== 1);
C.End(IndR) = [];
C.Start(nonzeros(IndR - 1)) = [];
C.Start(C.Start==0) = [];
C.End(C.End==0) = [];

end