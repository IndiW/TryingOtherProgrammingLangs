(defrecord GuardedCommand [guard command])

(defn allowed-commands
  [commands]
  (if (empty? commands) nil
      (let [[command & rest] commands]
      (printf "Checking command %s\n" (.command command))
        (if (eval (.guard command)) (concat [(.command command)](allowed-commands rest))
            (allowed-commands rest)))))

(defmacro guarded-if
  "Given a sequence of `GuardedCommands`, `commands`,
select a random guarded command whose `.guard` evaluates
to a truthy value and evaluate its `.command`."
  [& commands]
  ;; The body must be quoted, so that nothing is evaluated until runtime.
  `(eval ;; Evaluate...
    (rand-nth (allowed-commands
     [~@commands])))) 

(defmacro guarded-do
  "Given a sequence of `GuardedCommands`, `commands`,
keep completing the guarded command whose `.guard` evaluates
to a truthy value"
  [& commands]
  ;; The body must be quoted, so that nothing is evaluated until runtime.
  ;; get random command 
  ;; evaluate the command 
  ;; when its true, recurse
  ;; will result in unavoidable infinite loop if all guards are true
  (when `(eval `(eval ;; Evaluate...
    (rand-nth [commands]))) (println commands)) )


(defn gcd [a b]
  (guarded-if
  (GuardedCommand. `(= 0 ~b) a)
  ;;(GuardedCommand. `(= (GCD b (mod a b)) (GCD b (mod a b))) (GCD a b))
  (GuardedCommand. `(not= 0 ~b) `(gcd ~b (mod ~a ~b)))
  ))