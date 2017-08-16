import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


"""
TODO:
shuffle both X and Y
split train and test sets
"""

def import_data(fileName):
    with open(fileName, 'rb') as f:
        data = pd.read_csv(f)
        data = data.as_matrix()
        
        X = data[:, :-1]
        Y = data[:, -1]
        Y = Y.astype(np.int32)
        
    # normalize features
    for i in range(X.shape[1]):
        # print(np.amax(X[:,i]))
        X[:,i] = X[:,i]/np.amax(X[:,i])
        print(i, np.amax(X[:,i]))
    # print(X)
    
    np.random.seed(5)
    np.random.shuffle(X)
    np.random.seed(5)
    np.random.shuffle(Y)
    
    return X, Y


def yToInd(Y, K):
    N = len(Y)
    ind = np.zeros((N, K))
    for i in range(N):
        ind[i, Y[i]] = 1
    print(ind.shape)
    return ind


def forward(X, W1, b1, W2, b2):
    Z = 1/(1 + np.exp(-X.dot(W1)-b1)) # or np.exp(np.dot(-X, W1)-b1)
    A = np.dot(Z, W2) + b2
    # The following is the softmax process (exponentiation and normalization)
    expA = np.exp(A)
    Y = expA/expA.sum(axis=1, keepdims=True)
    return Y, Z


def classification_rate(Y, P):
    correct = 0
    total = 0
    for i in range(len(Y)):
        total += 1
        if Y[i] == P[i]:
            correct += 1
    return float(correct/total)


# I thought there was another log term in this function
def cost(T, Y):
    tot = T*np.log(Y)
    return tot.sum()


def derivative_w2(Z, T, Y):
    # ret2 = Z.T.dot(T-Y)
    ret2 = Z.T.dot(Y-T)
    return ret2


def derivative_b2(T, Y):
    # return (T-Y).sum(axis=0)
    return (Y - T).sum(axis=0)


def derivative_w1(X, Z, T, Y, W2):
    # int1 = np.dot((T-Y), W2.T)
    int1 = np.dot((Y-T), W2.T)
    int2 = int1*Z*(1-Z)
    int3 = np.dot(int2.T, X)
    return np.sum(int3, axis=1)

    # return np.sum(np.dot((T-Y).T, W2)*Z*(1-Z))

def derivative_b1(T, Y, W2, Z):
    # return ((T-Y).dot(W2.T)*Z*(1-Z)).sum(axis=0)
    return ((Y-T).dot(W2.T) * Z * (1 - Z)).sum(axis=0)

def main():
    # # create the data
    # nClass = 500
    # D = 2 # input dimensionality (num features)
    # M = 3 # hidden layer size
    # K = 2 # output dimensionality (num of classes)
    #
    # cloud = np.random.randn(nClass, 2)
    # X1 = cloud + np.array([0, -2])
    # X2 = cloud + np.array([2, 2])
    # X = np.vstack([X1, X2])
    #
    # Y = np.array([0] * nClass + [1] * nClass)
    # N = len(Y)

    X, Y = import_data('dataset.csv')

    D = X.shape[1] # input dimensionality (num features)
    M = 100 # hidden layer size
    K = 3 # output dimensionality (num of classes)

    XTrain = X[:-50, :]
    XTest = X[-50:, :]
    YTrain = Y[:-50]
    YTest = Y[-50:]
    TTrain = yToInd(YTrain, K)
    TTest = yToInd(YTest, K)

    # T = yToInd(Y,K)

    # plt.scatter(X[:,0], X[:,1], c=Y, s=100, alpha=0.5)
    # plt.show()

    # randomly initialize the weights
    W1 = np.random.randn(D, M)
    b1 = np.random.randn(M)
    W2 = np.random.randn(M, K)
    b2 = np.random.randn(K)

    learningRate = 10e-6
    costs = []
    costTrain = []
    costTest = []
    epochs = 2000
    for epoch in range(epochs):
        # output, hidden = forward(X, W1, b1, W2, b2)
        #
        # # every 100 epochs, calculate classification rate
        # if epoch % 100 == 0:
        #     cTrain = cost(T, output)
        #     P = np.argmax(output, axis=1)
        #     r = classification_rate(Y, P)
        #     c = cost(T, output)
        #     P = np.argmax(output, axis=1)
        #     r = classification_rate(Y, P)
        #     costs.append(c)
        #     if epoch % 5000 == 0:
        #         print(epoch)
        #         print('Cost: ', c)
        #         print('Classification Rate: ', r)
        # W2 += learningRate * derivative_w2(hidden, T, output)
        # b2 += learningRate * derivative_b2(T, output)
        # W1 += learningRate * derivative_w1(X, hidden, T, output, W2)
        # b1 += learningRate * derivative_b1(T, output, W2, hidden)
        
        outTrain, ZTrain = forward(XTrain, W1, b1, W2, b2)
        outTest, ZTest = forward(XTest, W1, b1, W2, b2)
        # every 100 epochs, calculate classification rate
        if epoch % 100 == 0:
            cTrain = cost(TTrain, outTrain)
            cTest = cost(TTest, outTest)
            PTrain = np.argmax(outTrain, axis=1)
            rTrain = classification_rate(YTrain, PTrain)
            PTest = np.argmax(outTest, axis=1)
            rTest = classification_rate(YTest, PTest)
            costTrain.append(cTrain)
            costTest.append(cTest)
            # if epoch % 5000 == 0:
            print(epoch)
            print('Train Cost: ', cTrain)
            print('Train Classification Rate: ', rTrain)
            print('Test Cost: ', cTest)
            print('Test Classification Rate: ', rTest)
        # W2 += learningRate * derivative_w2(ZTrain, TTrain, outTrain)
        # b2 += learningRate * derivative_b2(TTrain, outTrain)
        # W1 += learningRate * derivative_w1(XTrain, ZTrain, TTrain, outTrain, W2)
        # b1 += learningRate * derivative_b1(TTrain, outTrain, W2, ZTrain)
        W2 -= learningRate * derivative_w2(ZTrain, TTrain, outTrain)
        b2 -= learningRate * derivative_b2(TTrain, outTrain)
        W1 -= learningRate * derivative_w1(XTrain, ZTrain, TTrain, outTrain,
                                           W2)
        b1 -= learningRate * derivative_b1(TTrain, outTrain, W2, ZTrain)

    plt.plot(costTrain)
    plt.plot(costTest)
    plt.show()

if __name__ == main():
    main()
