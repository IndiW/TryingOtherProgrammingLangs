Pair = Struct.new(:fst,:snd)

def summingPairs(xs, sum)       
    len = xs.length
    mid = len/2
    reader, writer = IO.pipe
    fork do
      the_pairs = []
        for i in 0..(mid)
            for j in (i+1)..(len-1)
            if xs[i] + xs[j] <= sum
                #the_pairs.push(Pair.new(xs[i],xs[j]))
                the_pairs.push(xs[i])
                the_pairs.push(xs[j])
            end
            end
        end
        #puts the_pairs
        writer.puts(the_pairs)
    end
    fork do 
        the_pairs = []
        for i in mid..(len-1)
            for j in (i+1)..(len-1)
            if xs[i] + xs[j] <= sum
                #the_pairs.push(Pair.new(xs[i],xs[j]))
                the_pairs.push(xs[i])
                the_pairs.push(xs[j])
            end
            end
        end
        #puts the_pairs
        writer.puts(the_pairs)
    end
    writer.close
    Process.waitall
    #convert strings pairs to Pair objects
    pairs = []
    x = reader.gets
    x2 = 0
    two = false
    while x
      if two
        pairs.push(Pair.new(x2.to_i,x.to_i))
        x = reader.gets
        two = false
      else
        two = true 
        x2 = x 
        x = reader.gets
      end

    end
    #puts pairs
    return pairs
end
