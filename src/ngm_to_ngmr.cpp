#include <vector>
#include <string>
#include "ngm/include/ngm/ngm.hpp"
#include "Rcpp.h"
using namespace Rcpp;

// [[Rcpp::plugins(openmp)]]

class RcppNgramModel : public ngram::NgramModel {
    public:
        RcppNgramModel(
            int n = 3,
            double alpha = 1.0,
            double unseen_alpha = 1.0,
            bool normalise_length = true
        ) {
            NgramModel(n, alpha, unseen_alpha, normalise_length);
        }

        void update_texts(
            const std::vector<std::string>& texts
        ) {
            update(texts);
        }
        std::vector<double> lpmf_texts(
            const std::vector<std::string>& texts,
            int n_threads = 1
        ) const {
            return(lpmf(texts, n_threads));
        }
};

RCPP_MODULE(ngm_module) {
    class_<RcppNgramModel>( "RcppNgramModel" )
    .constructor<int,double,double,bool>()
    .method("update_texts", &RcppNgramModel::update_texts)
    .method("lpmf_texts", &RcppNgramModel::lpmf_texts)
    ;
}