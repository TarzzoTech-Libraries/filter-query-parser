FQP = PEG;

function conditionBuilder(rule) {
	const value = typeof rule.value === 'string' ? `"${rule.value}"` : rule.value;
	let condStr = `${rule.field} ${rule.operator} ${value}`;
	return condStr;
}

function queryBuilder(obj = []) {
	let qStr = '';
	const cond = obj.condition;
	const rules = obj.rules;
	rules.forEach((r, i) => {
		if (r.hasOwnProperty('field')) {
			if(qStr) {
				qStr = `${qStr} ${conditionBuilder(r)}`;
			} else {
				qStr = conditionBuilder(r);
			}
		} else if (r.hasOwnProperty('condition') && r.hasOwnProperty('rules')) {
			qStr = `${qStr}(${queryBuilder(r)})`;
		}
		if (i !== rules.length - 1) {
			qStr = `${qStr} ${cond} `;
		}
	});
	return qStr;
}

FQP.__proto__.stringify = function(obj) {
	if (typeof obj === 'object') {
		if (obj.hasOwnProperty('condition') && obj.hasOwnProperty('rules')) {
			if ((obj.condition && typeof obj.condition === 'string') && (obj.rules && typeof obj.rules === 'object')) {
				return queryBuilder(obj);
			} else {
				throw "Invalid format. Object should contain condition and rules";
			}
		} else {
			throw "Invalid format. Object should contain condition and rules";
		}
	} else {
		throw "Invalid object";
	}
}

if (!this.window) {
	module.exports = {
		FQP: FQP
	};
}
