:neg 
:abs 
:plus
:times
:minus 
:exp

class Expr
    def initialize(*args)
        type = args 

        case type[0]
        when :neg 
            @val = [type[0], type[1]]
        when :abs 
            @val = [type[0], type[1]]
        when :plus
            @val = [type[0], type[1],type[2]]
        when :times 
            @val = [type[0], type[1],type[2]]
        when :minus 
            @val = [type[0], type[1],type[2]]
        when :exp 
            @val = [type[0], type[1],type[2]]
        else
            @val = [type[0]]
        end
    end

    def get_val
        return @val
    end

    def interpret
        case @val[0]
        when :neg 
            return -interpret2(@val[1])
        when :abs 
            return abs(interpret2(@val[1]))
        when :plus
            return interpret2(@val[1]) + interpret2(@val[2])
        when :times 
            return interpret2(@val[1]) * interpret2(@val[2])
        when :minus 
            return interpret2(@val[1]) - interpret2(@val[2])
        when :exp 
            return interpret2(@val[1]) ** interpret2(@val[2])
        else
            return @val[0]
        end
    end

    def interpret2(ex)
        e = ex.get_val
        case e[0]
        when :neg 
            return -interpret2(e[1])
        when :abs 
            return abs(interpret2(e[1]))
        when :plus
            return interpret2(e[1]) + interpret2(e[2])
        when :times 
            return interpret2(e[1]) * interpret2(e[2])
        when :minus 
            return interpret2(e[1]) - interpret2(e[2])
        when :exp 
            return interpret2(e[1]) ** interpret2(e[2])
        else 
            return e[0]
        end
    end
end


def construct_const(i)
    return Expr. new(i)
end

def construct_neg(e)
    return Expr. new(:neg,e)
end

def construct_abs(e)
    return Expr. new(:abs,e)
end

def construct_plus(e1, e2)
    return Expr. new(:plus,e1,e2)
end

def construct_times(e1,e2)
    return Expr. new(:times,e1,e2)
end

def construct_minus(e1,e2)
    return Expr. new(:minus,e1,e2)
end

def construct_exp(e1,e2)
    return Expr. new(:exp,e1,e2)
end
