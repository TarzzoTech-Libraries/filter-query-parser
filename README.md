# filter-query-parser

Library for parsing the query string to an Object form and stringify Object to query string.


## Installation
```sh
$ npm install filter-query-parser
```

### Browser
```sh
<script src="..../FQP/dist/FQP.js"></script>
```

### node.js
```sh
const FQP = require('..../FQP/dist/FQP.js').FQP;
```

## Quick Start

Parse the query string to JavaScript Object

Query sample 1
```sh
const query = `Age <= 25 AND (Gender = "Male" OR School contains "School")`;
const Obj = FQP.parse(query);
```

Returns

```sh
{
  "condition":"AND",
  "rules": [
      {"field":"Age","operator":"<=","value":25},
      {
          "condition":"OR",
          "rules": [
              {"field":"Gender","operator":"=","value":"Male"},
              {"field":"School","operator":"CONTAINS","value":"School"}
          ],
          "not":false
      }
  ],
  "not":false
}
```

Query sample 2
```sh
const Obj = {
        "condition":"AND",
        "rules": [
            {"field":"Age","operator":"<=","value":25},
            {
                "condition":"OR",
                "rules": [
                    {"field":"Gender","operator":"=","value":"Male"},
                    {"field":"School","operator":"CONTAINS","value":"School"}
                ],
                "not":false
            }
        ],
        "not":false
    };
const query = FQP.stringify(Obj);
```

Returns

```sh
Age <= 25 AND (Gender = "Male" OR School contains "School")
```


## Grammar

### Supported data types for right value

| type    | example     |
| ---     | ---         |
| String  | "foo", "bar", ... |
| Number | 1, 200, -15, 14.5, ...       |
| Boolean | true false  |


### Logical Operators (case insensitive)

| operator | description         |
| ---      | ---                 |
| AND      | logical conjunction |
| OR       | logical sum         |
| !        | logical negation    |


### Comparison Operators (case insensitive)

| operator | description                                                                                                                              |
| ---      | ---                                                                                                                                      |
| =        | equal                                                                                                                                    |
| !=       | not equal                                                                                                                                |
| >=       | greater than or equal to                                                                                                                 |
| <=       | less than or equal to                                                                                                                    |
| >        | greater than                                                                                                                             |
| <        | less than                                                                                                                                |
| CONTAINS | Check if right value contains left value when right value is String<br>Or check if right value is in left array when left value is Array |


### Query examples

|      | sample queries                                            | description               |
|------|-----------------------------------------------------------|---------------------------|
| Good | name = "hoge"                                             | compare String            |
| Good | name contains "eorg"                                      | partial match with String |
| Good | age = 37, age < 30, age >= 3                              | compare Number            |
| Good | flag = true                                               | compare Boolean           |
| Good | name != "George"                                          | not equal                 |
| Good | person.age > 40                                           | JSON dot notation         |
| Good | k1 = "v1" AND k2 = "v2"                                   | AND operator              |
| Good | k1 = "v1" OR k2 = "v2"                                    | OR operator               |
| Good | k1 = "v1" AND k2 = "v2" ... AND kx= "vx"                  | multiple AND/OR operator  |
| BAD  | k1 = "v1" AND k2 = "v2" OR k3 = "v3"                      | mixed logical operators   |
| Good | ! (name contains "eorg")                                  | ! operator                |
| Good | (a = 1 AND b = 'foo') OR c = false                        | with brackets             |
| Good | (a = 1 OR b = 'foo') AND c = false                        | with brackets             |
| Good | (a = 1 OR b = 'foo') AND (c = false AND d CONTAINS 'bar') | with brackets             |
| BAD  | ((a = 1 AND b = 'foo') OR c = false) AND d CONTAINS 'bar' | nested brackets           |

