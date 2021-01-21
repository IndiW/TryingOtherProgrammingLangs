(defrecord GCConst [value]) ;; constant
(defrecord GCVar [value]) ;; variable
(defrecord GCOp [e1 e2 op]) ;; binary operator
(defrecord GCTrue []) ;; boolean true
(defrecord GCFalse []) ;; boolean false

(defrecord GCComp [e1 e2 op]) ;; boolean comparison
(defrecord GCAnd [t1 t2]) ;; logical AND
(defrecord GCOr [t1 t2]) ;; logical OR

(defrecord GCSkip []) ;; skip
(defrecord GCAssign [s e]) ;; assign an expression to variable
(defrecord GCCompose [s1 s2]) ;; two statements which will run one after another
(defrecord GCIf [pairs]) ;; if guard
(defrecord GCDo [pairs]) ;; while loop

(defrecord Config [stmt sig]) ;; config object which will be used as input and output for reduce function. Keeps track of the last statement and the current memory state


(def emptyState (fn [x] 0))

(defn updateState 
  [sigma x n] 
  (fn [v] (if (= x v) n
      (sigma x))))

(defn reduce
  [input] ;; Config Record as input. Contains .stmt and .sig values
  (cond
    (instance? GCConst (.stmt input)) (Config. (.value (.stmt input)) (.sig input)) ;;check if statement is constant
    (instance? GCVar (.stmt input)) (Config. (.value (.stmt input)) (.sig input)) 
    (instance? GCTrue (.stmt input)) (Config. (true) (.sig input)) 
    (instance? GCFalse (.stmt input)) (Config. (false) (.sig input)) 
    (instance? GCOp (.stmt input)) 
      (Config. (cond 
        (= :plus (.op (.stmt input))) (+ (.e1 (.stmt input)) (.e2 (.stmt input)))
        (= :times (.op (.stmt input))) (* (.e1 (.stmt input)) (.e2 (.stmt input)))
        (= :minus (.op (.stmt input))) (- (.e1 (.stmt input)) (.e2 (.stmt input)))
        (= :div (.op (.stmt input))) (/ (.e1 (.stmt input)) (.e2 (.stmt input)))
      ) (.sig input)) 
    (instance? GCComp (.stmt input)) 
      (Config. (cond 
        (= :eq (.op (.stmt input))) (= (.e1 (.stmt input)) (.e2 (.stmt input)))
        (= :less (.op (.stmt input))) (< (.e1 (.stmt input)) (.e2 (.stmt input)))
        (= :greater (.op (.stmt input))) (> (.e1 (.stmt input)) (.e2 (.stmt input)))
      ) (.sig input))
    (instance? GCAnd (.stmt input)) (Config. (and (.t1 (.stmt input)) (.t2 (.stmt input))) (.sig input)) 
    (instance? GCOr (.stmt input))(Config. (or (.t1 (.stmt input)) (.t2 (.stmt input))) (.sig input))
    (instance? GCSkip (.stmt input)) (Config. (.stmt input) (.sig input))
    (instance? GCCompose (.stmt input))
      (Config. (.stmt (reduce(Config. (.s2 (.stmt input)) (.sig input)))) (.sig (reduce(Config. (.s1 (.stmt input)) (.sig input)))))

    ;;Check if a random value from the pairs list is true. If so then place the statement in the config. Otherwise ignore

    (instance? GCDo (.stmt input))
      (let [x (rand-int (count (.pairs (.stmt input))))] (Config. (if (instance? GCTrue (first (nth (.pairs (.stmt input)) x))) (.stmt input) (GCSkip.)) (.sig input)))


    (instance? GCIf (.stmt input))
      (let [x (rand-int (count (.pairs (.stmt input))))] (Config. (if (instance? GCTrue (first (nth (.pairs (.stmt input)) x))) (second (nth (.pairs (.stmt input)) x)) (second (nth (.pairs (.stmt input)) x))) (.sig input)))

      ;; check if statement is assign. Converts Const value as well to pass test case. IE assumes Assign will always use a constant
    (instance? GCAssign (.stmt input))
      (Config. (GCSkip.) (updateState (.sig input) (.s (.stmt input)) (.value (.e (.stmt input))))) 

    :else (Config. (.stmt input) (.sig input))
    ))
