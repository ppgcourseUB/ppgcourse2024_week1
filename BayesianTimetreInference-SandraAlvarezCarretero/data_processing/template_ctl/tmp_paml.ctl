* [SEED NUMBER]

          seed = -1  * Timestamp is used to define the seed number

* [DEFINE PATH TO INPUT/OUTPUT FILES]

       seqfile = ALN                       * Path to input sequence file
      treefile = cytb_calib_MCMCtree.tree  * Path to input tree file
      mcmcfile = mcmc.txt                  * Path to output file with MCMC samples (option used by MCMCtree)
       outfile = out.txt                   * Path to log output file when running a PAML program

* [DEFINE CHARACTER DATA]

         ndata = NUMPARTS   * Number of alignment blocks (partitions) in the sequence file
       seqtype = 0          * 0: nucleotides; 1:codons; 2:AAs
     cleandata = 0          * Remove sites with ambiguity data (1:yes, 0:no)?

* [DEFINE TYPE OF ANALYSIS AND CLOCK MODEL]

       usedata = TYPEINF    * 0: no data (prior); 1:exact likelihood;
                            * 2:approximate likelihood; 3:out.BV (in.BV)
         clock = CLK        * 1: global clock; 2: uncorrelated rates; 3: correlated rates

* [DEFINE EVOLUTIONARY MODEL]

         model = 4    * 0:JC69, 1:K80, 2:F81, 3:F84, 4:HKY85
         alpha = 0.5  * Alpha for gamma rates at sites
         ncatG = 5    * No. categories in discrete gamma

* [MCMC SETTINGS]

       BDparas = 1 1 0.1   * Per-lineage birth rate (lambda), per-lineage death rate (mu),
                           * and sampling fraction (rho)
   rgene_gamma = 2 2.7     * gammaDir prior for rate for genes
  sigma2_gamma = 2 40      * gammaDir prior for sigma^2 (only when clock=2 or clock=3)

         print = 1         * 0: no mcmc sample; 1: everything except branch rates; 2: everything
        burnin = 20000     * Number of iterations that will be discarded as part of burn-in
      sampfreq = 100       * Sampling frequency
       nsample = 20000     * Number of samples to be collected

*** Note: Make your window wider (100 columns) before running the program from a Terminal
