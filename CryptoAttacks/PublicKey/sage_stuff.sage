def hastad_linear(keys, ciphertexts):
    '''Hastad broadcast attacks with linear padding function: c = (a*m + b)^e % n

    Args:
        keys(list of tuples): [(n1, e1), (n2, e2), ...]
        ciphertexts(list of tuples): [(c1, a1, b1), (c2, a2, b2), ...]

    Returns:
        msg(int/None)
    '''
    ni, ei = zip(*keys)
    ci, ai, bi = zip(*ciphertexts)
    N = reduce(lambda x, y: x * y, ni)
    ti = [long(N / n) * inverse_mod(long(N / n), n) for n in ni]

    K = Zmod(N)
    P.<m> = PolynomialRing(K, implementation='NTL')
    f = 0
    for i in xrange(len(ti)):
        t, a, b, c, n, e = ti[i], ai[i], bi[i], ci[i], ni[i], ei[i]
        if a != 1 and gcd(a, n) != 1:
            print "Found private key"
            p = gcd(a, n)
            q = long(n / p)
            assert p * q == n
            d = inverse_mod(e, (p - 1) * (q - 1))
            msg = pow(c, d, n)
            return long((msg - b) / a)
        # make it monic
        c = (c * inverse_mod(long(pow(a, e, n)), n)) % n
        f += t * ((m + b * inverse_mod(a, n)) ^ e - c)

    # print f
    msg = f.small_roots()
    if len(msg) > 0:
        return msg[0]
    return None