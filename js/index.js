import { RRule, RRuleSet, rrulestr } from 'rrule';
import { DateTime } from 'luxon';

export class Iterator {
    static iterate(ruleString, options, beginDate, endDate) {
        // Parse the rule
        var rule = rrulestr(ruleString, JSON.parse(options))        
        
        // Get all occurrence dates
        var events = rule.between(beginDate, endDate).map(date =>
            // Properly adjust it to UTC
            DateTime.fromJSDate(date)
              .toUTC()
              .setZone('local', { keepLocalTime: true })
              .toJSDate()
        )
        return events
    }
};
