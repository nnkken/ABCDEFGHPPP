#!/usr/bin/env ruby

if ARGV.length > 0
    WIDTH = ARGV[0].to_i
else
    WIDTH = 4
end

DIGITS = 4 * WIDTH + 1

if ARGV.length > 1
    BASE = ARGV[1].to_i
else
    BASE = DIGITS
end

class Solution
    RANGE = (0...BASE).to_a - [1]

    PRECOMPUTE_SUM = (0..(2 * BASE)).map { |sum|
        [
            sum,
            RANGE.product(RANGE)
            .select { |x, y|
                x + y == sum &&
                x != y &&
                RANGE.include?(x) &&
                RANGE.include?(y)
            }
        ]
    }
    .to_h

    POS_SUM = (0...WIDTH).map do |k1|
        k1 = k1 + 2 * WIDTH
        [
            k1,
            (0...WIDTH).map do |k2|
                k2 = k2 + 3 * WIDTH
                [
                    k2,
                    PRECOMPUTE_SUM.map do |sum, pairs|
                        if k1 == 2 * WIDTH
                            pairs = pairs.select { |x, y| x != 0 }
                        end
                        if k2 == 3 * WIDTH
                            pairs = pairs.select { |x, y| y != 0 }
                        end
                        [sum, pairs]
                    end
                    .to_h
                ]
            end
            .to_h
        ]
    end
    .to_h

    PRECOMPUTE_DIFF = (-BASE..BASE).map { |diff|
        [
            diff,
            RANGE.product(RANGE)
            .select { |x, y|
                x - y == diff &&
                x != y &&
                RANGE.include?(x) &&
                RANGE.include?(y)
            }
        ]
    }
    .to_h

    POS_DIFF = (0...WIDTH).map do |k1|
        [
            k1,
            (0...WIDTH).map do |k2|
                k2 = k2 + WIDTH
                [
                    k2,
                    PRECOMPUTE_DIFF.map do |diff, pairs|
                        if k1 == 0
                            pairs = pairs.select { |x, y| x != 0 }
                        end
                        if k2 == WIDTH
                            pairs = pairs.select { |x, y| y != 0 }
                        end
                        [diff, pairs]
                    end
                    .to_h
                ]
            end
            .to_h
        ]
    end
    .to_h

    def initialize(sol = nil, index = nil)
        @sol = (sol.nil? ? Array.new(DIGITS) : sol)
        @index = (index.nil? ? 0 : index)
    end

    def [](key)
        @sol[key]
    end

    def set(kv)
        newSol = @sol.clone
        newIndex = @index
        kv.each do |key, value|
            newSol[key] = value
            newIndex |= (1 << value)
        end
        Solution.new(newSol, newIndex)
    end

    def setPair(k1, v1, k2, v2)
        newSol = @sol.clone
        newIndex = @index
        newSol[k1] = v1
        newSol[k2] = v2
        newIndex |= (1 << v1) | (1 << v2)
        Solution.new(newSol, newIndex)
    end

    def pairs(k1, k2, from)
        from
        .select { |x, y| (@index & (1 << x)) == 0 && (@index & (1 << y)) == 0 }
        .map { |x, y| setPair(k1, x, k2, y) }
    end

    def pairsWithSum(k1, k2, sum)
        pairs(k1, k2, PRECOMPUTE_SUM[sum])
        pairs(k1, k2, POS_SUM[k1][k2][sum])
    end

    def pairsWithDiff(k1, k2, diff)
        # pairs(k1, k2, PRECOMPUTE_DIFF[diff])
        pairs(k1, k2, POS_DIFF[k1][k2][diff])
    end

    def to_s
        (
            (0..3)
            .map { |n| (n * WIDTH)...((n + 1) * WIDTH) }
            .map { |r|
                [
                    r.map { |i| ("A".getbyte(0) + i).chr }.join.to_sym,
                    @sol[r]
                ]
            } + [[("A".getbyte(0) + (4 * WIDTH)).chr.to_sym, @sol[-1]]]
        ).to_h.to_s
    end

    def inspect
        to_s
    end
end

baseSolution = Solution.new.set([[DIGITS - 1, 1]])
solutions = baseSolution
.pairsWithSum(DIGITS - WIDTH - 2, DIGITS - 2, BASE + 1)
.lazy

(3..(WIDTH + 1)).each do |w|
    solutions = solutions.flat_map { |sol|
        sol.pairsWithSum(DIGITS - WIDTH - w, DIGITS - w, BASE)
    }
end

solutions = solutions.flat_map { |sol|
    sol.pairsWithDiff(WIDTH - 1, 2 * WIDTH - 1, sol[3 * WIDTH - 1]) +
    sol.pairsWithDiff(WIDTH - 1, 2 * WIDTH - 1, sol[3 * WIDTH - 1] - BASE)
}

(2..(WIDTH - 1)).each do |w|
    solutions = solutions.flat_map { |sol|
        x = WIDTH - w
        y = x + WIDTH
        z = y + WIDTH
        acc = (sol[x + 1] < sol[y + 1] ? 1 : 0)
        sol.pairsWithDiff(x, y, sol[z] + acc) +
        sol.pairsWithDiff(x, y, sol[z] + acc - BASE)
    }
end
solutions = solutions.flat_map { |sol|
    acc = (sol[1] < sol[WIDTH + 1] ? 1 : 0)
    sol.pairsWithDiff(0, WIDTH, sol[2 * WIDTH] + acc)
}


t = Time.new
puts "width = #{WIDTH}, base = #{BASE}"
puts
puts "First 50 solutions:"
puts
puts solutions.take(50).force
puts

solutionCount = 0
solutions.each do |sol|
    solutionCount += 1
end
puts "Total number of solutions = #{solutionCount}"
puts "Time used = #{Time.new - t}s"
