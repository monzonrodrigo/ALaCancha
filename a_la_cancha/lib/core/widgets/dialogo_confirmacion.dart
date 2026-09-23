import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// RNF05: TODA accion critica/irreversible (cancelar turno, dar de baja
/// turno fijo, eliminar cancha) debe pasar por este dialogo antes de
/// ejecutarse. El boton de accion siempre nombra la accion especifica --
/// nunca un generico "OK" -- y "Volver" es siempre el boton neutro.
///
/// Devuelve `true` si el usuario confirmo, `false` o `null` si volvio atras.
Future<bool> mostrarDialogoConfirmacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoBotonConfirmar,
  String? avisoNeutral,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mensaje,
            style: const TextStyle(
              color: AppColors.textoSecundario,
              height: 1.4,
            ),
          ),
          if (avisoNeutral != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                avisoNeutral,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF3F3F46),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Volver'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.peligro),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(textoBotonConfirmar),
          ),
        ),
      ],
    ),
  );
  return confirmado ?? false;
}
