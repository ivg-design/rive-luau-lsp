-- Probe: canonical Rive test-protocol script (editor-validated convention)

function setup(test: Tester)
    local group = test.group
    local case = test.case

    group("values", function()
        case("equality", function(expect)
            expect(2 + 2).is(4)
            expect("hello").is("hello")
        end)
        case("ranges", function(expect)
            expect(3).lessThanOrEqual(3)
            expect(3).greaterThan(2)
            expect(4).never.greaterThanOrEqual(6)
        end)
        group("nested", function()
            case("inner", function(expect)
                expect(2 + 2).never.is(3)
            end)
        end)
    end)

    case("ungrouped", function(expect)
        expect(1).is(1)
    end)
end

return function(): Tests
    return setup
end
