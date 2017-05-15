"use strict";

const esprima = require("esprima");
const escodegen = require("escodegen");

const app = require("express")();

app.use(require("body-parser").json());

app.post("/esprima", (req, res) => {
    try {
        res.json(esprima.parse(req.body.input, req.body.config));
    } catch (err) {
        res.json({error: err});
    }
});

app.post("/escodegen", (req, res) => {
    try {
        res.json(escodegen.generate(req.body.input));
    } catch (err) {
        res.json({error: err});
    }
});

app.listen(require('minimist')(process.argv.slice(2)).port);
