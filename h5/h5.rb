def fizzbuzzLooper(a)
  n = a.length()-1
  for i in 0..n
    if a[i]%3==0 and a[i]%5==0
      a[i] = "fizzbuzz"
    elsif a[i]%3==0
      a[i] = "fizz"
    elsif a[i]%5==0
      a[i] = "buzz"
    else
      a[i] = a[i].to_s
    end
  end
  return a
end

def fizzbuzzIterator(a)
  a.collect!{|x|
    if x%3==0 and x%5==0
      "fizzbuzz"
    elsif x%3==0
      "fizz"
    elsif x%5==0
      "buzz"
    else
      x.to_s
    end
  }
  return a
end

def zuzzer(a, rules)
  a.collect!{|x|
    n = rules.length()-1
    s = ""
    for i in 0..n
      if rules[i][0].call(x)
        s += rules[i][1].call(x)
      end
    end
    if s.length() == 0
      s += x.to_s
    end
    x = s
  }
  return a
end
