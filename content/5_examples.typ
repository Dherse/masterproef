#import "../elems/acronyms.typ": *
#import "../elems/infos.typ": *
#import "../elems/template.typ": *

= Examples of photonic circuit programming <sec_examples>

Several different application areas were mentioned in @photonic_processors_use_cases, and in this section, some of these areas will be demonstrated using the @phos programming language. The examples are meant to be mockups of real applications, and are not meant to be complete implementations, focusing solely on the @phos part of their design. These examples will be explored in different levels of details depending on the complexity of the application and how much of the capabilities of @phos they demonstrate. The full code, with comments, and type annotations is available starting at @anx_lattice_filter.

== Lattice filter

== Spectrometer

=== Fixed bins implementation

=== Improved fixed bins implementation

== Beam forming

```phos
syn beam_forming(
    input: optical,
    phase_shifts: (electrical...),
) -> (optical...) {
    input
        |> split(splat(1.0, phase_shifts.len()))
        |> zip(phase_shifts)
        |> map(set modulate(type: Modulation::Phase))
        |> constrain(d_delay = 0)
}
```

== Coherent transceiver

```phos
syn coherent_transmitter(
    input: optical,
    (i, ni, q, nq): (electrical, electrical, electrical, electrical),
) -> optical {
    input
        |> split(splat(1.0, 4))
        |> modulate(type = Modulation::Amplitude)
        |> constrain(d_phase = 90 deg)
        |> merge()
}

syn coherent_receive(
    input: optical,
    ref: optical,
) -> (electrical, electrical) {
    input
        |> filter(1150 nm, 100 GHz)
        |> split((1.0, 1.0))
        |> zip(ref |> split((1.0, 1.0)))
        |> map(merge)
        |> map(demodulate)
}

syn main(
    ref: optical,
    input: optical,
    (i, ni, q, nq): (electrical, electrical, electrical, electrical),
) -> (optical, electrical, electrical) {
    let (i_out, q_out) = coherent_receive(input, ref);
    let output = coherent_transmitter(i, ni, q, nq);

    (output, i_out, q_out)
}
```

== Fiber sensing

```phos

syn fiber_sensor(
    input: optical,
    @len(refs.len())
    wavelengths: (Wavelength...),
    @len(wavelengths.len())
    refs: (optical...),
    measure: bool,
) -> (optical, electrical, ...) {
    let out = if measure {
        refs |> merge()
    } else {
        empty()
    };

    input
        |> split(splat(1.0, wavelengths.len()))
        |> zip(wavelengths)
        |> map(set filter(bandwidth = 1 GHz))
        |> map(demodulate)
}

```

== Switch matrix

#raw_offset(16)
```phos
syn matrix(
    inputs: (optical, ...),
    switches: (bool, ...),
) -> (optical, ...) {

}
```

== Analog matrix multiplication