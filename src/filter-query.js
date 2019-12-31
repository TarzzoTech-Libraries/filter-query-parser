function buildArrayValues(values) {
	let txt = ''
	values.forEach((val,i) =>{      
		txt += (typeof val === 'string' ? `"${val}"` : val);
		if (i !== values.length - 1) {
			txt += ',';
		}
	});
	return txt;
}

function conditionBuilder(rule, customField) {
	const value = rule.value && typeof rule.value === 'string' ?
	  `"${rule.value}"` : typeof rule.value === 'object' ? `(${buildArrayValues(rule.value)})` : rule.value;
	const condStr = `${rule[customField] || rule.field} ${getOperator(rule.operator)} ${value}`;
	return condStr;
}

function getOperator(operator){
	switch(operator){
	  case("greater than"):
	   return ">"; 
	   case("lesser than"):
	   return "<";
	   case("greater than or equals"):
	   return ">="; 
	   case("lesser than or equals"):
	   return "<=";
	   case("equals"):
	   return "=";
	   case("not equals"):
	   return "!=";
	   default : return operator;
	}
}

function queryBuilder(obj = [], customField) {
	let qStr = '';
	const cond = obj.condition;
	const rules = obj.rules;
	rules.forEach((r, i) => {
		if (r.hasOwnProperty(customField || 'field')) {
			if(qStr) {
				qStr = `${qStr}${conditionBuilder(r, customField)}`;
			} else {
				qStr = conditionBuilder(r, customField);
			}
		} else if (r.hasOwnProperty('condition') && r.hasOwnProperty('rules')) {
			qStr = `${qStr}(${queryBuilder(r, customField)})`;
		}
		if (i !== rules.length - 1) {
			qStr = `${qStr} ${cond} `;
		}
	});
	return qStr;
}

const FQP = {
	...PEG,
	stringify(obj, customField = '') {
		if (typeof obj === 'object') {
			if (obj.hasOwnProperty('condition') && obj.hasOwnProperty('rules')) {
				if ((obj.condition && typeof obj.condition === 'string') && (obj.rules && typeof obj.rules === 'object')) {
					return queryBuilder(obj, customField);
				} else {
					throw "Invalid format. Object should contain condition and rules";
				}
			} else {
				throw "Invalid format. Object should contain condition and rules";
			}
		} else {
			throw "Invalid object";
		}
	},
	parser(query) {
		const parsedVal = FQP.parse(query);
		if (typeof parsedVal === 'object' && parsedVal.hasOwnProperty('field')) {
			return {
				condition: 'AND',
				rules: [parsedVal]
			};
		} else {
			return parsedVal;
		}
	}
};

if (!this.window) {
	module.exports = {
		FQP: FQP
	};
}
