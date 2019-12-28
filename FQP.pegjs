///// Class Definition /////
{

    const LogicalOperator = {
        AND: "AND",
        OR: "OR",
        fromString: function (str) {
            str = str.toUpperCase();
            const items = [LogicalOperator.AND, LogicalOperator.OR];
        for (const item of items) {
            if (item === str) {
                    return item;
                }
        }
        throw new Error(`Not supported: logical operator:${str}`);
        }
    };

    const cops = [
        ['GE', '>='],
        ['LE', '<='],
        ['EQ', '='],
        ['NE', '!=='],
        ['GT', '>'],
        ['LT', '<'],
        ['CONTAINS', 'CONTAINS'],
        ['SW', 'STARTS WITH'],
        ['EW', 'ENDS WITH']
    ];
    class ComparisonOperator {
        constructor(name, op) {
            this.name = name;
            this.op = op;
        let fml;
        if (name === 'CONTAINS') {
            fml = `(a === undefined || a === null) ? false : a.includes(b)`;
            } else {
                fml = `a ${op} b`;
        }
            this.func = function (a, b) {
                return eval(fml);
            };
        }

        static fromString(str) {
            switch (str) {
            case '=':
        str = '='; break;
            case '!=':
        str = '!=='; break;
            default:
            str = str.toUpperCase(); break;
            }
            const items = cops.map(x => ComparisonOperator[x[0]]);
        for (const item of items) {
            if (item.op === str) {
                    return item;
                }
        }
        throw new Error(`Not supported: comparison operator:${str}`);
        }
    }
    for (const cop of cops) {
        const name = cop[0];
        const op = cop[1];
        ComparisonOperator[name] = new ComparisonOperator(name, op);
    }


    class Rule {
        constructor(k, op, v) {
            this.field = k;
            this.operator = op.op;
            this.value = v;
        }
    }

    class RuleSet {
        constructor(op, conditions) {
            this.condition = op;
            this.rules = conditions;
        }
    }

}


start = Expression

///// Keywords /////
Escape   = "\\"
AND      = v:("AND" / "and") { return v.toUpperCase(); }
OR       = v:("OR" / "or") { return v.toUpperCase(); }
EQ       = "="
NE       = "!="
GT       = ">"
GE       = ">="
LT       = "<"
LE       = "<="
CONTAINS = v:("CONTAINS" / "contains") { return v.toUpperCase(); }
SW = v:("STARTS WITH" / "starts with") { return v.toUpperCase(); }
EW = v:("ENDS WITH" / "ends with") { return v.toUpperCase(); }
L_PAR    = "("
R_PAR    = ")"
DQ       = '"'
TRUE     = 'true'
FALSE    = 'false'
NOT      = '!'


///// Types /////
DIGIT     = [0-9]
HEXDIG    = [0-9a-f]i
ws        = [ \t\n\r]*
Unescaped = [\x20-\x21\x23-\x5B\x5D-\u10FFFF]
String    = DQ chars:Char* DQ { return chars.join(""); }
Number    = [\+\-]?[0-9]+("." [0-9]+)? { return Number(text()); }
Boolean   = v:(TRUE / FALSE) { return v.toLowerCase() === 'true'; }
Key       = [^=\(\) \t\n\r]+ { return text(); }
Value     = String / Number / Boolean
Char
  = Unescaped
  / Escape
    sequence:(
        '"'
      / "\\"
      / "/"
      / "b" { return "\b"; }
      / "f" { return "\f"; }
      / "n" { return "\n"; }
      / "r" { return "\r"; }
      / "t" { return "\t"; }
      / "u" digits:$(HEXDIG HEXDIG HEXDIG HEXDIG) {
          return String.fromCharCode(parseInt(digits, 16));
        }
     )
   { return sequence; }


///// Operators /////
ComparisonOperator
  = op:(GE / LE / EQ / NE / GT / LT / CONTAINS / SW / EW) { return ComparisonOperator.fromString(text()); }

LogicalOperator
  = AND / OR { return LogicalOperator.fromString(text()); }


///// Expression /////
Expression
  = ws g:Grammar ws { return g; }

Grammar
  = cg:RuleSets { return cg; }


RuleSets
  = conds:(
      head:RuleSet
      tail:(ws op:LogicalOperator ws cg:RuleSet { return { op:op, cg:cg }; })?
      {
        if (!tail) {
            const items = [head];
            return head;
        } else {
            const items = [head, tail.cg];
            const op = tail.op;
            const cg = new RuleSet(op, items);
            return cg;
        }
      }
    )

RuleSet
  = L_PAR ws cg:_RuleSet ws R_PAR { return cg; }
    / NOT ws L_PAR ws cg:_RuleSet ws R_PAR { cg.not = true; return cg; }
    / cg:_RuleSet { return cg; }

_RuleSet
  = conds:(
      head:(cond:Rule { return { op:LogicalOperator.AND, cond:cond}; })
      tail:(ws op:LogicalOperator ws cond:Rule { return { op:op, cond:cond }; })*
      {
        const items = [head].concat(tail);
        const conds = items.map(x => { return x.cond; });
        let cg;
        if (items.length === 1) {
            cg = items[0].cond;
        } else {
                const ops = items.map(x => { return x.op; });
            ops.shift();
                const opSet = new Set(ops);
                if (opSet.size > 1) {
                    throw 'AND and OR cannot be used together';
                }
            const op = opSet.values().next().value;
            cg = new RuleSet(op, conds);
	    }
	return cg;
      }
    )?	

Rule
  = k:Key ws op:ComparisonOperator ws v:Value { return new Rule(k, op, v); }
