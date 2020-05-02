import 'package:flutter/material.dart';

class DropdownFormFieldNormalReuse extends StatefulWidget {
  final String hintText;
  final dynamic selectedValue;
  final List<String> listData;

  final onUpdateSelectionValue;

  DropdownFormFieldNormalReuse(this.onUpdateSelectionValue,
      {@required this.hintText,
      @required this.selectedValue,
      @required this.listData});

  //ToDo check of set state is ok in this widget using bloc

  @override
  _DropdownFormFieldNormalReuseState createState() =>
      _DropdownFormFieldNormalReuseState();
}

class _DropdownFormFieldNormalReuseState
    extends State<DropdownFormFieldNormalReuse> {
  var setselectedValue;

  @override
  Widget build(BuildContext context) {
    print("dropdown valuue: ${widget.selectedValue}");
    setselectedValue = widget.selectedValue;

    return Container(
        child: Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(10.00),
            child: DropdownButton<String>(
              //decoration: InputDecoration(filled: true),
              hint: Text(widget.hintText),
              value: setselectedValue,
              onChanged: (String newValue) {
                setState(() {
                  setselectedValue = newValue;
                  widget.onUpdateSelectionValue(newValue);
                });
              },
              items: widget.listData.map((String dropDownStringItem) {
                return new DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: new Text(
                    dropDownStringItem,
                    style: new TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              isExpanded: true,
            ))
      ],
    ));
  }
}
