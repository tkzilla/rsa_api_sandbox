import numpy as np
import pandas as pd

def extract_data(fileName):
    with open(fileName, 'rb') as f:
        data = pd.read_csv(f)
        data = data.as_matrix()
        
        X = data[:, :-1]
        Y = data[:, -1]
        
    np.random.shuffle(X)
    np.random.shuffle(Y)
    
    return X, Y


def main():
    fileName = 'dataset.csv'
    X, Y = extract_data(fileName)
    

if __name__ == '__main__':
    main()