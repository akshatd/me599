% prediction function

function yhat = akshat_hwk2_p3_predict(x)
load('akshat_hwk2_p3_weights.mat');
O1 = sig(W1'*x + W1_0);
yhat = soft(W2'*O1 + W2_0);
[~, yhat] = max(yhat);
end

function Y = soft(X)
Y = exp(X)./ (sum(exp(X)));
end

function Y = sig(X)
Y = 1./(1+exp(-X));
end
