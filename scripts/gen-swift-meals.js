// Port the dish database to Swift straight from the JS, so nothing is retyped.
const fs = require('fs');
const MEALS = new Function(fs.readFileSync('/home/user/Dinner-Decider/js/meals.js','utf8') + '; return MEALS;')();

const U = { hand: '.hand', fork: '.fork', spoon: '.spoon', chop: '.chopsticks' };
const H = { protein: '.protein', veg: '.vegetable', carbs: '.carbs' };
const W = { cold: '.cold', hot: '.hot', mild: '.mild' };
const D = { omni: '.omnivore', veg: '.vegetarian', vegan: '.vegan' };
const q = (s) => '"' + s.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';

const CHUNK = 40;
const chunks = [];
for (let i = 0; i < MEALS.length; i += CHUNK) chunks.push(MEALS.slice(i, i + CHUNK));

const body = chunks.map((chunk, ci) => {
  const rows = chunk.map(m =>
    `        Meal(${q(m.n)}, ${q(m.e)}, ${q(m.o)}, ${q(m.b)},\n` +
    `             u: [${m.u.map(x => U[x]).join(', ')}], m: ${m.m}, ` +
    `s: [${m.s.join(', ')}], f: [${m.f.join(', ')}], ` +
    `h: [${m.h.map(x => H[x]).join(', ')}], a: [${m.a.join(', ')}], ` +
    `w: [${m.w.map(x => W[x]).join(', ')}], d: ${D[m.d]})`
  ).join(',\n');
  return `    private static func part${ci + 1}() -> [Meal] {\n        [\n${rows}\n        ]\n    }`;
}).join('\n\n');

const out = `//
//  Meals.swift
//  What should I eat for dinner?
//
//  GENERATED from js/meals.js — do not edit by hand.
//  Regenerate with: node scripts/gen-swift-meals.js
//
//  ${MEALS.length} dishes, each tagged against all eight questions.
//

import Foundation

enum MealDatabase {

    /// Every dish the matcher can choose from.
    static let all: [Meal] = {
        var meals: [Meal] = []
        meals.reserveCapacity(${MEALS.length})
${chunks.map((_, i) => `        meals.append(contentsOf: part${i + 1}())`).join('\n')}
        return meals
    }()

${body}
}
`;
fs.writeFileSync('/home/user/Dinner-Decider/ios/DinnerDecider/Model/Meals.swift', out);
console.log(`Meals.swift written: ${MEALS.length} dishes in ${chunks.length} chunks, ${(out.length/1024).toFixed(1)} KB`);
