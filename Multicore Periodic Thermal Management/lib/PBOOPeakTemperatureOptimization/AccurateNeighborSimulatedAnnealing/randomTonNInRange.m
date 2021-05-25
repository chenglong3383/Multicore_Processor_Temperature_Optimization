function newTonN = randomTonNInRange(current_tonN, ubTonN, lbTonN, currentTemperature, initialTemperature)

isInputColumn = iscolumn(current_tonN);


current_tonN = current_tonN(:)';
ubTonN = ubTonN(:)';
lbTonN = lbTonN(:)';
currentTemperature = currentTemperature(:)';
initialTemperature = initialTemperature(:)';

nvar = numel(current_tonN);
miniTemp = 1;

deltaPos = ubTonN - current_tonN;
deltaNeg = current_tonN - lbTonN;

invalid1 = deltaPos < 1;
invalid2 = deltaNeg < 1;

eta_min1 = 1 ./ deltaPos;
eta_min1(invalid1) = 0;
eta_min2 = 1 ./ deltaNeg;
eta_min2(invalid2) = 0;
eta_max1 =  ones(1, nvar);
eta_max2 =  ones(1, nvar);
eta_max1(invalid1) = 0;
eta_max2(invalid2) = 0;

eta1 = getEta(eta_min1, eta_max1, currentTemperature, initialTemperature, miniTemp);
eta2 = getEta(eta_min2, eta_max2, currentTemperature, initialTemperature, miniTemp);

delta = eta1 .* deltaPos .* rand(1, nvar) -  eta2 .* deltaNeg;

newTonN = current_tonN + round(delta(:)');

if isInputColumn
    newTonN = newTonN(:);
end

    function [eta] = getEta(eta_min, eta_max, currentTemperature, initialTemperature, miniTemp)
       miniTemperatureRatio = miniTemp ./ initialTemperature;
       eta_k = (eta_max - eta_min) ./ (1 - miniTemperatureRatio);
       eta_b = eta_max - eta_k;
       
       eta = eta_k .* (currentTemperature ./ initialTemperature) + eta_b;
        
    end

end