import 'package:expenses/components/chart.dart';
import 'package:expenses/components/transaction_form.dart';
import 'package:expenses/components/transaction_list.dart';

import 'package:expenses/models/transaction.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    ExpenseApp(),
  );
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp // desabilita rotacionar a tela mantendo portrait Up
    // ]);
    final ThemeData thema = ThemeData();
    return MaterialApp(
      home: MyHomePage(),
      theme: thema.copyWith(
        colorScheme: thema.colorScheme.copyWith(
            primary: Colors.purple,
            secondary: Colors.green,
            tertiary: Colors.amber),
        textTheme: thema.textTheme.copyWith(
          titleLarge: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(
      () {
        _transactions.add(newTransaction);
      },
    );

    Navigator.of(context).pop();
  }

  _openTransactionFormModal(BuildContext context) {
    // Abre modal para adicionar transação
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape; // Verifica se o equipamento esta landscape
    final appBar = AppBar(
      title: Text(
        'Despesas pessoais',
        style: TextStyle(fontSize: 20),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      actions: <Widget>[
        if (isLandscape)
          Container(
            height: 60,
            width: 60,
            child: FractionallySizedBox(
              widthFactor:
                  0.6, // 60% da largura do Container heightFactor: 0.6,
              child: IconButton(
                icon: Icon(_showChart ? Icons.list : Icons.show_chart),
                onPressed: () {
                  setState(() {
                    _showChart = !_showChart;
                  });
                  // função que abre modal
                },
              ),
            ),
          ),
        Container(
          height: 60,
          width: 60,
          child: FractionallySizedBox(
            widthFactor: 0.6, // 60% da largura do Container heightFactor: 0.6,
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _openTransactionFormModal(context);
                // função que abre modal
              },
            ),
          ),
        ),
      ],
    );

    final availableHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Exibir Grafico'),
                  Switch(
                    value: _showChart,
                    onChanged: (value) {
                      setState(() {
                        _showChart = value;
                      });
                    },
                  ),
                ],
              ),
            if (_showChart || !isLandscape)
              Container(
                height: availableHeight * (isLandscape ? 0.7 : 0.3),
                child: Chart(_recentTransactions),
              ),
            if (!_showChart || !isLandscape)
              Container(
                height: availableHeight * 0.7,
                child: TransactionList(_transactions, _removeTransaction),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          size: 30,
          color: Colors.black,
        ),
        onPressed: () {
          _openTransactionFormModal(context);
          // função que abre modal
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
