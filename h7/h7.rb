require_relative "a2_ulterm"

$q = Array.new

ULVar.class_eval{
    def prettify()
            prettify_track(97)
    end

    def helper(count)
    end

    def prettify_track(n)
        if $q.empty?
            return (@index.to_s.to_i + 97).chr
        end
        value = $q.shift
        return (value).chr
    end
}

ULApp.class_eval{
    def prettify()
        prettify_track(97)
    end

    def helper(count)
    end

    def prettify_track(n)
        "(" + @t1.prettify_track(n) + ") (" + @t2.prettify_track(n) + ")" 
    end
}

ULAbs.class_eval{
    def prettify_track( n)
        "lambda " + n.chr + " . " + @t.prettify_track(n + 1)
    end

    def helper(count)
        $q.unshift count
        @t.helper(count + 1)
    end

    def prettify()
        helper(97)
        prettify_track(97)
    end
}
