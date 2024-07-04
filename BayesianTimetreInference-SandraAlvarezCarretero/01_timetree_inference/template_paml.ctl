          seed = -1                        * Used timestamp to define seed number
       seqfile = ALN                       * Path to input sequence file
      treefile = cytb_calib_MCMCtree.tree  * Path to input tree file
      mcmcfile = mcmc.txt                  * Path to output file with MCMC samples
       outfile = out.txt                   * Path to log output file

         ndata = NUMPART  * Number of partitions
       seqtype = 0        * 0: nucleotides; 1:codons; 2:AAs
     cleandata = 0        * remove sites with ambiguity data (1:yes, 0:no)?

       usedata = TYPEINF  * 0: no data (prior); 1:exact likelihood; 2:approximate likelihood; 3:out.BV (in.BV)
         clock = CLK      * 1: global clock; 2: independent rates; 3: correlated rates

         model = 4        * 0:JC69, 1:K80, 2:F81, 3:F84, 4:HKY85
         alpha = 0.5      * alpha for gamma rates at sites
         ncatG = 5        * No. categories in discrete gamma

       BDparas = 1 1 0.1  * birth, death, sampling
   rgene_gamma = 2 2.7    * gammaDir prior for rate for genes
  sigma2_gamma = 2 40     * gammaDir prior for sigma^2

         print = 1        * 0: no mcmc sample; 1: everything except branch rates; 2: everything
        burnin = 2000     * Number of iterations that will be discarded as part of burn-in
      sampfreq = 100      * Sampling frequency
       nsample = 20000    * Number of samples to be collected

*** Note: Make your window wider (100 columns) before running the program.