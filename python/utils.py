import numpy as np
from scipy.sparse.linalg import eigsh

def get_powerlaw(ss, trange):
    ''' fit exponent to variance curve'''
    logss = np.log(np.abs(ss))
    y = logss[trange][:,np.newaxis]
    trange += 1
    nt = trange.size
    x = np.concatenate((-np.log(trange)[:,np.newaxis], np.ones((nt,1))), axis=1)
    w = 1.0 / trange.astype(np.float32)[:,np.newaxis]
    b = np.linalg.solve(x.T @ (x * w), (w * x).T @ y).flatten()
    
    allrange = np.arange(0, ss.size).astype(int) + 1
    x = np.concatenate((-np.log(allrange)[:,np.newaxis], np.ones((ss.size,1))), axis=1)
    ypred = np.exp((x * b).sum(axis=1))
    alpha = b[0]
    return alpha,ypred

def cvPCA(sresp0, nshuff=5):
    ss = np.zeros((sresp0.shape[1],))
    NN = sresp0.shape[-1]
    nstims = sresp0.shape[1]
    fullCOV = np.reshape(sresp0, (-1, NN)) @ np.reshape(sresp0, (-1, NN)).T
    for n in range(nshuff):
        if n == 0:
            inr = np.zeros((nstims,), np.bool)
        else:
            inr = np.random.rand(nstims) < 0.5
        sresp = sresp0.copy()
        sresp[np.ix_([0,1], inr.nonzero()[0])] = sresp0[np.ix_([1,0], inr.nonzero()[0])]
        istims1 = np.inf * np.ones((nstims,))
        istims1[~inr] = (~inr).nonzero()[0]
        istims1[~inr] = (~inr).nonzero()[0]
        istims2 = np.inf * np.ones((nstims,))
        istims2[inr] = (inr).nonzero()[0]
        istims2[inr] = (inr).nonzero()[0]
        istims = np.argsort(np.concatenate((istims1,istims2), axis=0))
        istims = istims[:nstims]
        sv,u = eigsh(fullCOV[np.ix_(istims, istims)], k=min(1024,sresp.shape[1]))
        u = u[:,::-1]
        sv = sv[::-1]
        cproj0 = sresp[0] @ (sresp[0].T @ u / sv**0.5)
        cproj1 = sresp[1] @ (sresp[0].T @ u / sv**0.5)
        ss += (cproj0 * cproj1).sum(axis=0)
    return ss