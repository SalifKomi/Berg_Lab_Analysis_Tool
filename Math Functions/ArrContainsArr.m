function logical = ArrContainsArr(A,B)

    size_B = length(B);%define number of element in array B
    C = intersect(A,B);%find intersection between A & B
    size_C = length(C);%define number of element in array C
    if size_C == size_B %if A contain all element in B
        logical = 1;
    else 
        logical = 0;
    end
end 