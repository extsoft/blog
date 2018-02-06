---
layout: post
title: "Test design techniques"
description: "The list of approaches for designing a great system tests coverage."
tags: [test design techniques]
comments: true
---
**Test Design** is creating a set of inputs for given software that will provide a set of expected outputs. So, as it's a creative process it'll be good to have a set of rules or approaches that guarantee the quality of a final output (usually tests or test cases).

The set of approaches is called "Test design techniques". Below you could find a list of them I have been collecting during last several years:
- [dynamic testing](https://www.tutorialspoint.com/software_testing_dictionary/dynamic_testing.htm)
  - [structure-based (whitebox)](http://istqbexamcertification.com/what-is-white-box-or-structure-based-or-structural-testing-techniques/)
    - [statement coverage*](http://istqbexamcertification.com/what-is-statement-coverage-advantages-and-disadvantages/)
    - [branch/decision coverage*](http://istqbexamcertification.com/what-is-decision-coverage-its-advantages-and-disadvantages/)
    - [condition coverage*](http://istqbexamcertification.com/what-is-condition-coverage/)
    - [modified condition/decision coverage](https://www.tutorialspoint.com/software_testing_dictionary/modified_condition_coverage.htm)
    - [basis path testing](https://www.tutorialspoint.com/software_testing_dictionary/basis_path_testing.htm)
    - [lcsaj testing](https://www.tutorialspoint.com/software_testing_dictionary/lcsaj_testing.htm)
  - [experience-based](http://istqbexamcertification.com/what-is-experience-based-testing-technique/)
    - [error guessing*](http://istqbexamcertification.com/what-is-error-guessing-in-software-testing/)
    - [exploratory testing*](http://istqbexamcertification.com/what-is-exploratory-testing-in-software-testing/)
  - [specification-based (blackbox)](http://istqbexamcertification.com/what-is-black-box-specification-based-also-known-as-behavioral-testing-techniques/)
    - [equivalence partitioning*](http://istqbexamcertification.com/what-is-equivalence-partitioning-in-software-testing/)
    - [boundary value analysis*](http://istqbexamcertification.com/what-is-boundary-value-analysis-in-software-testing/)
    - [state transition testing*](http://istqbexamcertification.com/what-is-state-transition-testing-in-software-testing/)
    - [use case testing*](http://istqbexamcertification.com/what-is-use-case-testing-in-software-testing/)
    - [combinatorial test design](http://research.ibm.com/haifa/dept/svt/papers/The_value_of_CTD.pdf)
      - [decision tables*](http://istqbexamcertification.com/what-is-decision-table-in-software-testing/)
      - [cause and effect graph](http://www.softwaretestingclass.com/what-is-cause-and-effect-graph-testing-technique/)
      - [classification tree testing](http://www.systematic-testing.com/documents/star1994.pdf)
      - [pairwise testing](https://www.tutorialspoint.com/software_testing_dictionary/pairwise_testing.htm)
    - [fuzz testing](https://www.tutorialspoint.com/software_testing_dictionary/fuzz_testing.htm)
    - [scenario testing](https://www.tutorialspoint.com/software_testing_dictionary/scenario_testing.htm)
    - [syntax testing](https://www.tutorialspoint.com/software_testing_dictionary/syntax_testing.htm)
- [static testing](https://www.tutorialspoint.com/software_testing_dictionary/static_testing.htm)
  - [review](https://swtestingconcepts.wordpress.com/basic-testing-concepts/reviews/)
    - [informal review*](http://istqbexamcertification.com/what-is-informal-reviews/)
    - [walkthrough*](http://istqbexamcertification.com/what-is-walkthrough-in-software-testing/)
    - [technical review*](http://istqbexamcertification.com/what-is-technical-review-in-software-testing/)
    - [inspection*](http://istqbexamcertification.com/what-is-inspection-in-software-testing/)
  - [static analysis](https://en.wikipedia.org/wiki/Static_program_analysis)
    - [data flow](https://en.wikipedia.org/wiki/Data-flow_analysis)
    - [control flow](https://en.wikipedia.org/wiki/Control_flow_analysis)

`*` -- ISTQB-related techniques

P.S. You are using the list at your own risk as it may be imperfect or have some inaccuracies. Please leave a comment if something has to be changed.
