import 'package:flutter/material.dart';

class SubtitleDialog extends StatefulWidget {
  final String? currentSubtitle;
  final Function(String?) onSubtitleChanged;

  const SubtitleDialog({
    Key? key,
    this.currentSubtitle,
    required this.onSubtitleChanged,
  }) : super(key: key);

  @override
  State<SubtitleDialog> createState() => _SubtitleDialogState();
}

class _SubtitleDialogState extends State<SubtitleDialog> {
  String? selectedSubtitle;
  
  // Lista estática de subtítulos
  final List<Map<String, String?>> subtitleOptions = [
    {'label': 'Desactivados', 'value': null},
    {'label': 'Español latino', 'value': 'es-latin'},
    {'label': 'Inglés', 'value': 'en'},
    {'label': 'Inglés - Descriptivo', 'value': 'en-desc'},
    {'label': 'Portugués', 'value': 'pt'},
    {'label': 'Italiano', 'value': 'it'},
    {'label': 'Japonés', 'value': 'ja'},
    {'label': 'Francés', 'value': 'fr'},
    {'label': 'Alemán', 'value': 'de'},
  ];

  @override
  void initState() {
    super.initState();
    selectedSubtitle = widget.currentSubtitle;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtítulos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Lista de subtítulos
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: subtitleOptions.length,
                itemBuilder: (context, index) {
                  final option = subtitleOptions[index];
                  final isSelected = selectedSubtitle == option['value'];
                  
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.2) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected 
                          ? Border.all(color: Colors.white, width: 1)
                          : null,
                    ),
                    child: ListTile(
                      title: Text(
                        option['label']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      leading: Radio<String?>(
                        value: option['value'],
                        groupValue: selectedSubtitle,
                        onChanged: (String? value) {
                          setState(() {
                            selectedSubtitle = value;
                          });
                        },
                        activeColor: Colors.white,
                        fillColor: MaterialStateProperty.all(Colors.white),
                      ),
                      onTap: () {
                        setState(() {
                          selectedSubtitle = option['value'];
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 20),
            
            // Botones de acción
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onSubtitleChanged(selectedSubtitle);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Aplicar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
          

  }
}