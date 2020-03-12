//
//  AlValidationRuleType.swift
//  ALTextField
//
//  Created by Alexandr Lobanov on 12.03.2020.
//  Copyright © 2020 Alexandr Lobanov. All rights reserved.
//

import Validator

protocol AlValidationRuleType {
    var rule: ValidationRuleSet<String> { get }
}

struct ALValidationError: ValidationError {

    public let message: String

    public init(_ message: String) {
        self.message = message
    }
}

struct EmailRule: AlValidationRuleType {
    var rule: ValidationRuleSet<String> {
        let rule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ALValidationError("Email is not valid."))
        return ValidationRuleSet(rules: [rule])
    }
}


struct PasswordRule: AlValidationRuleType {
    var rule: ValidationRuleSet<String> {
        var passwordRules = ValidationRuleSet<String>()
        
        let min = 8
        let minLengthRule = ValidationRuleLength(min: min, error: ALValidationError("Password have to contain at least \(min) symbols"))
        passwordRules.add(rule: minLengthRule)
        
        let digitRule = ValidationRulePattern(pattern: ContainsNumberValidationPattern(), error: ALValidationError("Password have to contain at less one digit."))
        
        passwordRules.add(rule: digitRule)
        return passwordRules
    }
}

struct UsernameRule: AlValidationRuleType {
    var rule: ValidationRuleSet<String> {
        var rules = ValidationRuleSet<String>()
        let min = 5
        let minLengthRule = ValidationRuleLength(min: min, error: ALValidationError("Username have to contain at least \(min) symbols"))
        rules.add(rule: minLengthRule)
        return rules
    }
}
