import os
import re

lib_dir = r"c:\Users\Acer\Desktop\Led Truck\ledtruck\lib"

def run():
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = content
                
                # 2. .withOpacity -> .withValues(alpha: )
                new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', new_content)
                
                # 3. value: -> initialValue:
                if file in ['modal_editar_dispositivo.dart', 'modal_vincular_carro.dart']:
                    new_content = re.sub(r'(\s+)value: (selected[A-Za-z0-9_]+),', r'\1initialValue: \2,', new_content)
                
                # 4. Remove go_router in franqueado_campanhas
                if file == 'franqueado_campanhas_screen.dart':
                    new_content = re.sub(r"import 'package:go_router/go_router\.dart';\r?\n?", "", new_content)
                
                # 5. dialogBackgroundColor -> dialogTheme.backgroundColor
                if file == 'base_components.dart':
                    new_content = new_content.replace('dialogBackgroundColor', 'dialogTheme.backgroundColor')
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated: {filepath}")

if __name__ == "__main__":
    run()
