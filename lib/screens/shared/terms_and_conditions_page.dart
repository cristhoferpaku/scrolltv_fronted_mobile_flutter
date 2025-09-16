import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/gradient_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/atoms/container_focus.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/organisms/home_navbar.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/app_scaffold.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class TermsSectionItem {
  final String title;
  final List<String> items;

  TermsSectionItem({required this.title, required this.items});
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final bool isTV = PlatformUtils.isTV;

  List<TermsSectionItem> sections = [
    TermsSectionItem(
      title: "",
      items: [
        "<b>Última actualización: [Septiembre 2025]</b>",
        "En <b>Scrolltv</b> respetamos su privacidad y nos comprometemos a proteger los datos personales que comparte con nosotros. Esta Política de Privacidad explica cómo recopilamos, usamos, almacenamos y compartimos su información cuando utiliza nuestros servicios de streaming.",
      ],
    ),
    TermsSectionItem(
      title: "1. Información que recopilamos",
      items: [
        "Podemos recopilar los siguientes tipos de datos personales:",
        "<b>Datos de registro:</b> nombre completo, correo electrónico, número de teléfono, fecha de nacimiento, género, contraseña.",
        "<b>Datos de uso:</b> historial de visualización, búsquedas, listas de favoritos, calificaciones, interacciones con la plataforma."
      ],
    ),
    TermsSectionItem(
      title: "2. Uso de la información",
      items: [
        "Utilizamos los datos recopilados para:",
        "*Proporcionar y mantener el servicio.",
        "*Procesar pagos y facturación.",
        "*Personalizar la experiencia del usuario y ofrecer recomendaciones.",
        "*Mejorar nuestras funcionalidades, seguridad y rendimiento.",
        "*Prevenir fraudes y actividades no autorizadas.",
        "*Enviar notificaciones, promociones y actualizaciones (previo consentimiento)."
      ],
    ),
    TermsSectionItem(title: "3. Compartición de información", items: [
      "Podemos compartir su información con:",
      "<b>Proveedores de servicios:</b> empresas que nos ayudan con pagos, almacenamiento en la nube, soporte técnico y análisis de datos.",
      "<b>Socios comerciales:</b> titulares de licencias de contenido y aliados estratégicos, cuando sea necesario para la operación.",
      "<b>Autoridades competentes:</b> cuando la ley lo requiera o sea necesario para proteger nuestros derechos y la seguridad de los usuarios.",
      "Nunca vendemos sus datos personales a terceros.",
    ]),
    TermsSectionItem(title: "4. Derechos del usuario", items: [
      "Usted tiene derecho a:",
      "*Acceder a sus datos personales.",
      "*Solicitar la corrección o actualización de su información.",
      "*Solicitar la eliminación de su cuenta y datos.",
      "*Retirar el consentimiento previamente otorgado.",
      "*Oponerse al tratamiento de sus datos para fines de marketing.",
      "Para ejercer estos derechos, puede contactarnos a través de <b>support@scrolltv.com</b>.",
    ]),
    TermsSectionItem(title: "5. Cookies y tecnologías similares", items: [
      "Utilizamos cookies y tecnologías de rastreo para:",
      "*Mantener la sesión iniciada.",
      "*Recordar sus preferencias de visualización.",
      "*Analizar tendencias y mejorar la experiencia de usuario.",
      "Usted puede configurar su navegador para rechazar cookies, aunque algunas funciones del servicio podrían verse afectadas."
    ]),
    TermsSectionItem(title: "6. Retención de datos", items: [
      "Conservamos sus datos mientras mantenga una cuenta activa en la plataforma. Una vez eliminada la cuenta, la información podrá conservarse por un periodo adicional únicamente para cumplir con obligaciones legales o resolver disputas."
    ]),
    TermsSectionItem(title: "7. Seguridad", items: [
      "Adoptamos medidas técnicas, administrativas y organizativas para proteger sus datos personales frente a accesos no autorizados, pérdidas o alteraciones. Sin embargo, ningún sistema de transmisión de datos es 100% seguro, por lo que no podemos garantizar seguridad absoluta."
    ]),
    TermsSectionItem(title: "8. Transferencias internacionales", items: [
      "Sus datos pueden ser transferidos y almacenados en servidores ubicados en otros países. En estos casos, aseguramos que se aplican medidas de protección adecuadas conforme a la normativa vigente."
    ]),
    TermsSectionItem(title: "9. Cambios en la política de privacidad", items: [
      "Podemos actualizar esta Política de Privacidad en cualquier momento. Le notificaremos de cambios significativos a través de la plataforma o por correo electrónico, antes de que entren en vigor."
    ]),
    TermsSectionItem(title: "10. Contacto", items: [
      "Si tiene preguntas o desea ejercer sus derechos de privacidad, puede comunicarse con nosotros en:",
      "<b>Scrolltv</b>",
      "<b>Correo electrónico:</b> support@scrolltv.com",
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundImage: isTV ? ImageAssets.backgroundTv : ImageAssets.backgroundMobile,
      linearGradient: GradientManager().background(),
      body: FocusTraversalGroup(
        policy: CustomGridTraversalPolicyStrictVertical(),
        child: ListView(
          shrinkWrap: true,
          children: [
            HomeNavbar(),
            SizedBox(height: AppPadding.p16.r),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppPadding.p8.r,
                children: [
                  Center(
                    child: Text(
                      "Políticas de Privacidad",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Column(
                    spacing: AppPadding.p24.r,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections
                        .map((section) => ContainerFocus(
                              onTap: () {},
                              showBorder: true,
                              scale: 1,
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  spacing: AppPadding.p8.r,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (section.title.isNotEmpty)
                                      Text(
                                        section.title,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ...section.items.map((item) {
                                      // Si el texto empieza con "*", renderizamos como bullet
                                      if (item.startsWith("*")) {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("• ").withPadding(left: AppPadding.p8.r),
                                            Expanded(
                                              child: buildFormattedText(item.substring(1).trim(), context),
                                            ),
                                          ],
                                        );
                                      } else {
                                        // Texto normal
                                        return buildFormattedText(item, context);
                                      }
                                    }),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
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

Widget buildFormattedText(String text, BuildContext context) {
  final regex = RegExp(r"<b>(.*?)<\/b>");
  final matches = regex.allMatches(text);

  if (matches.isEmpty) {
    return Text(text, style: Theme.of(context).textTheme.bodyMedium);
  }

  final spans = <TextSpan>[];
  int lastIndex = 0;

  for (final match in matches) {
    if (match.start > lastIndex) {
      spans.add(TextSpan(
        text: text.substring(lastIndex, match.start),
        style: Theme.of(context).textTheme.bodyMedium,
      ));
    }
    spans.add(TextSpan(
      text: match.group(1),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    ));
    lastIndex = match.end;
  }

  if (lastIndex < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastIndex),
      style: Theme.of(context).textTheme.bodyMedium,
    ));
  }

  return RichText(text: TextSpan(children: spans));
}
