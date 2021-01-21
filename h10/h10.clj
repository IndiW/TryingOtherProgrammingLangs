(defn summingPairs [xs sum]
  (letfn [(summingPairsHelper [xs the_pairs]
            ;; If `xs` is empty, we're done.
            (if (empty? xs) the_pairs
                ;; Otherwise, decompose `xs` into the `fst` element
                ;; and the `rest`.
                (let [[fst & rest] xs]
                  ;; We use the `recur` form to make the recursive call.
                  ;; This ensures tail call optimisation
                  (let [other (future(summingPairsHelper rest the_pairs))]
                   (doall 
                    (concat the_pairs
                            (for [snd rest :when (<= (+ fst snd) sum)] [fst snd])
                              
                              @other))
                    ;;(concat the_pairs @other)
                              
                              ))))]
    (summingPairsHelper xs [])))
